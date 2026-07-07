import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:grad_project/features/video_call/data/services/signalr_hub_service.dart';
import 'package:grad_project/features/video_call/data/services/video_call_api_service.dart';
import 'package:grad_project/features/video_call/data/models/participant_model.dart';
import 'participants_state.dart';

class ParticipantsCubit extends Cubit<ParticipantsState> {
  final SignalrHubService hubService;
  final VideoCallApiService apiService;

  String? _localId;
  String? _localName;

  final List<StreamSubscription> _subscriptions = [];

  ParticipantsCubit({
    required this.hubService,
    required this.apiService,
  }) : super(const ParticipantsState(participants: [])) {
    _subscribeToHubEvents();
  }

  Future<void> loadParticipants(
    String meetingId, {
    required String localId,
    required String localName,
  }) async {
    _localId = localId.toLowerCase();
    _localName = localName;
    try {
      final participants = await apiService.getMeetingParticipants(meetingId);
      final list = List<ParticipantModel>.from(participants);
      
      // Ensure local participant is present
      if (!list.any((p) => p.id.toLowerCase() == _localId)) {
        list.add(ParticipantModel(
          id: _localId!,
          name: _localName!,
          isAudioEnabled: true,
          isVideoEnabled: true,
        ));
      }
      emit(state.copyWith(participants: list));
    } catch (e) {
      debugPrint('ParticipantsCubit: Failed to load participants: $e');
      // Set at least local participant in case API fails
      emit(state.copyWith(participants: [
        ParticipantModel(
          id: _localId!,
          name: _localName!,
          isAudioEnabled: true,
          isVideoEnabled: true,
        )
      ]));
    }
  }

  void _subscribeToHubEvents() {
    _subscriptions.addAll([
      hubService.participantJoinedStream.listen((payload) {
        final newParticipant = ParticipantModel(
          id: payload.participantId.toLowerCase(),
          name: payload.fullName,
          isAudioEnabled: payload.isAudioEnabled,
          isVideoEnabled: payload.isVideoEnabled,
          isScreenSharing: payload.isScreenSharing,
          isHandRaised: payload.isHandRaised,
        );
        final list = List<ParticipantModel>.from(state.participants);
        // Avoid duplicate additions
        list.removeWhere((p) => p.id.toLowerCase() == newParticipant.id);
        list.add(newParticipant);
        emit(state.copyWith(participants: list));
      }),

      hubService.participantLeftStream.listen((participantId) {
        final list = List<ParticipantModel>.from(state.participants)
          ..removeWhere((p) => p.id.toLowerCase() == participantId.toLowerCase());
        emit(state.copyWith(participants: list));
      }),

      hubService.existingParticipantsStream.listen((listPayload) {
        final list = listPayload.map((payload) {
          return ParticipantModel(
            id: payload.participantId.toLowerCase(),
            name: payload.fullName,
            isAudioEnabled: payload.isAudioEnabled,
            isVideoEnabled: payload.isVideoEnabled,
            isScreenSharing: payload.isScreenSharing,
            isHandRaised: payload.isHandRaised,
          );
        }).toList();

        // Keep local participant in the list if they are not already there
        if (_localId != null && _localName != null) {
          if (!list.any((p) => p.id.toLowerCase() == _localId)) {
            list.add(ParticipantModel(
              id: _localId!,
              name: _localName!,
              isAudioEnabled: true,
              isVideoEnabled: true,
            ));
          }
        }
        emit(state.copyWith(participants: list));
      }),

      hubService.participantAudioToggledStream.listen((payload) {
        final list = state.participants.map((p) {
          if (p.id.toLowerCase() == payload.participantId.toLowerCase()) {
            return p.copyWith(isAudioEnabled: payload.enabled);
          }
          return p;
        }).toList();
        emit(state.copyWith(participants: list));
      }),

      hubService.participantVideoToggledStream.listen((payload) {
        final list = state.participants.map((p) {
          if (p.id.toLowerCase() == payload.participantId.toLowerCase()) {
            return p.copyWith(isVideoEnabled: payload.enabled);
          }
          return p;
        }).toList();
        emit(state.copyWith(participants: list));
      }),

      hubService.screenSharingStartedStream.listen((participantId) {
        final list = state.participants.map((p) {
          if (p.id.toLowerCase() == participantId.toLowerCase()) {
            return p.copyWith(isScreenSharing: true);
          }
          return p;
        }).toList();
        emit(state.copyWith(participants: list));
      }),

      hubService.screenSharingStoppedStream.listen((participantId) {
        final list = state.participants.map((p) {
          if (p.id.toLowerCase() == participantId.toLowerCase()) {
            return p.copyWith(isScreenSharing: false);
          }
          return p;
        }).toList();
        emit(state.copyWith(participants: list));
      }),

      hubService.participantHandRaisedStream.listen((payload) {
        final list = state.participants.map((p) {
          if (p.id.toLowerCase() == payload.participantId.toLowerCase()) {
            return p.copyWith(isHandRaised: payload.raised);
          }
          return p;
        }).toList();
        emit(state.copyWith(participants: list));
      }),
    ]);
  }

  void updateParticipantAudio(String participantId, bool enabled) {
    final list = state.participants.map((p) {
      if (p.id.toLowerCase() == participantId.toLowerCase()) {
        return p.copyWith(isAudioEnabled: enabled);
      }
      return p;
    }).toList();
    emit(state.copyWith(participants: list));
  }

  void updateParticipantVideo(String participantId, bool enabled) {
    final list = state.participants.map((p) {
      if (p.id.toLowerCase() == participantId.toLowerCase()) {
        return p.copyWith(isVideoEnabled: enabled);
      }
      return p;
    }).toList();
    emit(state.copyWith(participants: list));
  }

  void updateParticipantHand(String participantId, bool raised) {
    final list = state.participants.map((p) {
      if (p.id.toLowerCase() == participantId.toLowerCase()) {
        return p.copyWith(isHandRaised: raised);
      }
      return p;
    }).toList();
    emit(state.copyWith(participants: list));
  }

  void pinParticipant(String? participantId) {
    emit(state.copyWith(pinnedParticipantId: participantId));
  }

  Future<void> muteAll(String meetingId) async {
    try {
      await hubService.muteAllParticipants(meetingId);
    } catch (e) {
      debugPrint('ParticipantsCubit: Failed to mute all: $e');
    }
  }

  Future<void> kickParticipant(String meetingId, String participantId) async {
    try {
      await hubService.kickParticipant(meetingId, participantId);
    } catch (e) {
      debugPrint('ParticipantsCubit: Failed to kick participant: $e');
    }
  }

  @override
  Future<void> close() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    return super.close();
  }
}

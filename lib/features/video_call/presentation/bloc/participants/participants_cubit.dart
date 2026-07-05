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

  final List<StreamSubscription> _subscriptions = [];

  ParticipantsCubit({
    required this.hubService,
    required this.apiService,
  }) : super(const ParticipantsState(participants: [])) {
    _subscribeToHubEvents();
  }

  Future<void> loadParticipants(String meetingId) async {
    try {
      final participants = await apiService.getMeetingParticipants(meetingId);
      emit(state.copyWith(participants: participants));
    } catch (e) {
      debugPrint('ParticipantsCubit: Failed to load participants: $e');
    }
  }

  void _subscribeToHubEvents() {
    _subscriptions.addAll([
      hubService.participantJoinedStream.listen((payload) {
        final newParticipant = ParticipantModel(
          id: payload.participantId,
          name: payload.fullName,
          isAudioEnabled: payload.isAudioEnabled,
          isVideoEnabled: payload.isVideoEnabled,
          isScreenSharing: payload.isScreenSharing,
          isHandRaised: payload.isHandRaised,
        );
        final list = List<ParticipantModel>.from(state.participants);
        // Avoid duplicate additions
        list.removeWhere((p) => p.id == newParticipant.id);
        list.add(newParticipant);
        emit(state.copyWith(participants: list));
      }),

      hubService.participantLeftStream.listen((participantId) {
        final list = List<ParticipantModel>.from(state.participants)
          ..removeWhere((p) => p.id == participantId);
        emit(state.copyWith(participants: list));
      }),

      hubService.existingParticipantsStream.listen((listPayload) {
        final list = listPayload.map((payload) {
          return ParticipantModel(
            id: payload.participantId,
            name: payload.fullName,
            isAudioEnabled: payload.isAudioEnabled,
            isVideoEnabled: payload.isVideoEnabled,
            isScreenSharing: payload.isScreenSharing,
            isHandRaised: payload.isHandRaised,
          );
        }).toList();
        emit(state.copyWith(participants: list));
      }),

      hubService.participantAudioToggledStream.listen((payload) {
        final list = state.participants.map((p) {
          if (p.id == payload.participantId) {
            return p.copyWith(isAudioEnabled: payload.enabled);
          }
          return p;
        }).toList();
        emit(state.copyWith(participants: list));
      }),

      hubService.participantVideoToggledStream.listen((payload) {
        final list = state.participants.map((p) {
          if (p.id == payload.participantId) {
            return p.copyWith(isVideoEnabled: payload.enabled);
          }
          return p;
        }).toList();
        emit(state.copyWith(participants: list));
      }),

      hubService.screenSharingStartedStream.listen((participantId) {
        final list = state.participants.map((p) {
          if (p.id == participantId) {
            return p.copyWith(isScreenSharing: true);
          }
          return p;
        }).toList();
        emit(state.copyWith(participants: list));
      }),

      hubService.screenSharingStoppedStream.listen((participantId) {
        final list = state.participants.map((p) {
          if (p.id == participantId) {
            return p.copyWith(isScreenSharing: false);
          }
          return p;
        }).toList();
        emit(state.copyWith(participants: list));
      }),

      hubService.participantHandRaisedStream.listen((payload) {
        final list = state.participants.map((p) {
          if (p.id == payload.participantId) {
            return p.copyWith(isHandRaised: payload.raised);
          }
          return p;
        }).toList();
        emit(state.copyWith(participants: list));
      }),
    ]);
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

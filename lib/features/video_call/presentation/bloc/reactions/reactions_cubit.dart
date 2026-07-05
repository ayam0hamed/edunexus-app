import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:grad_project/features/video_call/data/services/signalr_hub_service.dart';
import 'reactions_state.dart';
import 'package:uuid/uuid.dart';

class ReactionsCubit extends Cubit<ReactionsState> {
  final SignalrHubService hubService;

  final List<StreamSubscription> _subscriptions = [];
  final Map<String, Timer> _activeTimers = {};

  ReactionsCubit({
    required this.hubService,
  }) : super(const ReactionsState(raisedHands: {}, recentReojis: [])) {
    _subscribeToReactionEvents();
  }

  void _subscribeToReactionEvents() {
    _subscriptions.addAll([
      hubService.participantHandRaisedStream.listen((payload) {
        final set = Set<String>.from(state.raisedHands);
        if (payload.raised) {
          set.add(payload.participantId);
        } else {
          set.remove(payload.participantId);
        }
        emit(state.copyWith(raisedHands: set));
      }),

      hubService.participantReactionStream.listen((payload) {
        final reactionId = const Uuid().v4();
        final event = ReactionEvent(
          id: reactionId,
          emoji: payload.emoji,
          fullName: payload.fullName,
          timestamp: DateTime.now(),
        );

        final list = List<ReactionEvent>.from(state.recentReojis)..add(event);
        emit(state.copyWith(recentReojis: list));

        // Start a 3-second timer to auto-clear this reaction from the screen
        _activeTimers[reactionId] = Timer(const Duration(seconds: 3), () {
          final updatedList = List<ReactionEvent>.from(state.recentReojis)
            ..removeWhere((e) => e.id == reactionId);
          emit(state.copyWith(recentReojis: updatedList));
          _activeTimers.remove(reactionId);
        });
      }),
    ]);
  }

  Future<void> toggleHandRaise(String meetingId, String participantId, bool raised) async {
    try {
      await hubService.raiseHand(meetingId, raised);
      final set = Set<String>.from(state.raisedHands);
      if (raised) {
        set.add(participantId);
      } else {
        set.remove(participantId);
      }
      emit(state.copyWith(raisedHands: set));
    } catch (e) {
      debugPrint('ReactionsCubit: Failed to raise hand: $e');
    }
  }

  Future<void> sendReaction(String meetingId, String emoji) async {
    try {
      await hubService.sendReaction(meetingId, emoji);
    } catch (e) {
      debugPrint('ReactionsCubit: Failed to send reaction: $e');
    }
  }

  @override
  Future<void> close() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    for (var timer in _activeTimers.values) {
      timer.cancel();
    }
    return super.close();
  }
}

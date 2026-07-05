import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:grad_project/features/video_call/data/services/signalr_hub_service.dart';
import 'package:grad_project/features/video_call/data/services/video_call_api_service.dart';
import 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  final SignalrHubService hubService;
  final VideoCallApiService apiService;

  final List<StreamSubscription> _subscriptions = [];

  QuizCubit({
    required this.hubService,
    required this.apiService,
  }) : super(const QuizInitial()) {
    _subscribeToQuizEvents();
  }

  void _subscribeToQuizEvents() {
    _subscriptions.addAll([
      hubService.quizStartedStream.listen((session) {
        emit(QuizActive(session: session, results: const {}));
      }),

      hubService.quizEndedStream.listen((sessionId) {
        final currentState = state;
        if (currentState is QuizActive) {
          emit(QuizEndedState(sessionId: sessionId, results: currentState.results));
        } else {
          emit(QuizEndedState(sessionId: sessionId, results: const {}));
        }
      }),

      hubService.quizResultsUpdatedStream.listen((results) {
        final currentState = state;
        if (currentState is QuizActive) {
          emit(currentState.copyWith(results: results as Map<String, dynamic>? ?? const {}));
        }
      }),
    ]);
  }

  Future<void> createAndStartQuiz(String meetingId, List<Map<String, dynamic>> questions) async {
    try {
      final sessionId = await apiService.createQuizSession(meetingId, questions);
      if (sessionId.isNotEmpty) {
        final session = await apiService.startQuiz(sessionId);
        emit(QuizActive(session: session, results: const {}));
      }
    } catch (e) {
      debugPrint('QuizCubit: Failed to create or start quiz: $e');
    }
  }

  Future<void> stopQuiz(String sessionId) async {
    try {
      await apiService.stopQuiz(sessionId);
      final results = await apiService.getQuizResults(sessionId);
      emit(QuizEndedState(sessionId: sessionId, results: results));
    } catch (e) {
      debugPrint('QuizCubit: Failed to stop quiz: $e');
    }
  }

  Future<bool> submitAnswer(String questionId, String selectedOption) async {
    try {
      return await apiService.answerQuizQuestion(questionId, selectedOption);
    } catch (e) {
      debugPrint('QuizCubit: Failed to submit quiz answer: $e');
      return false;
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

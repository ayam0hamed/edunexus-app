import 'package:equatable/equatable.dart';
import 'package:grad_project/features/video_call/data/models/quiz_models.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {
  const QuizInitial();
}

class QuizActive extends QuizState {
  final QuizSessionModel session;
  final Map<String, dynamic> results;

  const QuizActive({
    required this.session,
    required this.results,
  });

  QuizActive copyWith({
    QuizSessionModel? session,
    Map<String, dynamic>? results,
  }) {
    return QuizActive(
      session: session ?? this.session,
      results: results ?? this.results,
    );
  }

  @override
  List<Object?> get props => [session, results];
}

class QuizEndedState extends QuizState {
  final String sessionId;
  final Map<String, dynamic> results;

  const QuizEndedState({
    required this.sessionId,
    required this.results,
  });

  @override
  List<Object?> get props => [sessionId, results];
}

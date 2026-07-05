import 'package:equatable/equatable.dart';

class QuizSessionModel extends Equatable {
  final String sessionId;
  final String meetingId;
  final String status; // 'Created', 'Active', 'Ended'
  final String? startedAt;
  final List<QuizQuestionModel> questions;

  const QuizSessionModel({
    required this.sessionId,
    required this.meetingId,
    required this.status,
    this.startedAt,
    required this.questions,
  });

  factory QuizSessionModel.fromJson(Map<String, dynamic> json) {
    final questionsList = json['questions'] as List?;
    return QuizSessionModel(
      sessionId: json['sessionId']?.toString() ?? json['id']?.toString() ?? '',
      meetingId: json['meetingId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Created',
      startedAt: json['startedAt']?.toString(),
      questions: questionsList != null
          ? questionsList
              .whereType<Map<String, dynamic>>()
              .map(QuizQuestionModel.fromJson)
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'meetingId': meetingId,
        'status': status,
        'startedAt': startedAt,
        'questions': questions.map((q) => q.toJson()).toList(),
      };

  @override
  List<Object?> get props => [sessionId, meetingId, status, startedAt, questions];
}

class QuizQuestionModel extends Equatable {
  final String id;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final int orderIndex;

  const QuizQuestionModel({
    required this.id,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.orderIndex,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id']?.toString() ?? '',
      questionText: json['questionText']?.toString() ?? '',
      optionA: json['optionA']?.toString() ?? '',
      optionB: json['optionB']?.toString() ?? '',
      optionC: json['optionC']?.toString() ?? '',
      optionD: json['optionD']?.toString() ?? '',
      orderIndex: json['orderIndex'] is int ? json['orderIndex'] as int : (int.tryParse(json['orderIndex']?.toString() ?? '0') ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'questionText': questionText,
        'optionA': optionA,
        'optionB': optionB,
        'optionC': optionC,
        'optionD': optionD,
        'orderIndex': orderIndex,
      };

  @override
  List<Object?> get props => [id, questionText, optionA, optionB, optionC, optionD, orderIndex];
}

import 'package:equatable/equatable.dart';
import 'package:grad_project/features/meetings/data/models/meeting_model.dart';

abstract class MeetingState extends Equatable {
  const MeetingState();

  @override
  List<Object?> get props => [];
}

class MeetingInitial extends MeetingState {
  const MeetingInitial();
}

class MeetingLoading extends MeetingState {
  const MeetingLoading();
}

class MeetingSuccess extends MeetingState {
  final String message;
  const MeetingSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class MeetingLoaded extends MeetingState {
  final int studentsCount;
  final int meetingsCount;
  final String instructorId;
  final String instructorName;
  final List<MeetingModel> meetings;

  const MeetingLoaded({
    required this.studentsCount,
    required this.meetingsCount,
    required this.instructorId,
    required this.instructorName,
    required this.meetings,
  });

  @override
  List<Object?> get props => [
        studentsCount,
        meetingsCount,
        instructorId,
        instructorName,
        meetings,
      ];
}

class MeetingError extends MeetingState {
  final String message;
  const MeetingError(this.message);

  @override
  List<Object?> get props => [message];
}

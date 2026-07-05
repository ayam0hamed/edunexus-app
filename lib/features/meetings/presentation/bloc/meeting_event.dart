import 'package:equatable/equatable.dart';

abstract class MeetingEvent extends Equatable {
  const MeetingEvent();

  @override
  List<Object?> get props => [];
}

class LoadMeetingsEvent extends MeetingEvent {
  final bool forceRefresh;
  const LoadMeetingsEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class CreateMeetingEvent extends MeetingEvent {
  final String meetingTitle;
  final String courseTitle;
  final String date;
  final String time;
  final String duration;
  final String maxAttendees;

  const CreateMeetingEvent({
    required this.meetingTitle,
    required this.courseTitle,
    required this.date,
    required this.time,
    required this.duration,
    required this.maxAttendees,
  });

  @override
  List<Object?> get props => [
        meetingTitle,
        courseTitle,
        date,
        time,
        duration,
        maxAttendees,
      ];
}

class RefreshMeetingsEvent extends MeetingEvent {
  const RefreshMeetingsEvent();
}

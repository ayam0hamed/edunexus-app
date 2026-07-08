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



class RefreshMeetingsEvent extends MeetingEvent {
  const RefreshMeetingsEvent();
}

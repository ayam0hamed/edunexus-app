import 'package:equatable/equatable.dart';

abstract class VideoCallState extends Equatable {
  const VideoCallState();

  @override
  List<Object?> get props => [];
}

class VideoCallInitial extends VideoCallState {
  const VideoCallInitial();
}

class VideoCallLoading extends VideoCallState {
  const VideoCallLoading();
}

class VideoCallJoined extends VideoCallState {
  final String meetingId;
  final String participantId;
  final String userName;
  final bool isInstructor;

  const VideoCallJoined({
    required this.meetingId,
    required this.participantId,
    required this.userName,
    required this.isInstructor,
  });

  @override
  List<Object?> get props => [meetingId, participantId, userName, isInstructor];
}

class VideoCallLeft extends VideoCallState {
  const VideoCallLeft();
}

class VideoCallError extends VideoCallState {
  final String message;

  const VideoCallError(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

abstract class MediaState extends Equatable {
  const MediaState();

  @override
  List<Object?> get props => [];
}

class MediaInitial extends MediaState {
  const MediaInitial();
}

class MediaReady extends MediaState {
  final MediaStream localStream;
  final bool isAudioOn;
  final bool isVideoOn;
  final bool isScreenSharing;

  const MediaReady({
    required this.localStream,
    this.isAudioOn = true,
    this.isVideoOn = true,
    this.isScreenSharing = false,
  });

  MediaReady copyWith({
    MediaStream? localStream,
    bool? isAudioOn,
    bool? isVideoOn,
    bool? isScreenSharing,
  }) {
    return MediaReady(
      localStream: localStream ?? this.localStream,
      isAudioOn: isAudioOn ?? this.isAudioOn,
      isVideoOn: isVideoOn ?? this.isVideoOn,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
    );
  }

  @override
  List<Object?> get props => [localStream, isAudioOn, isVideoOn, isScreenSharing];
}

class MediaError extends MediaState {
  final String message;

  const MediaError(this.message);

  @override
  List<Object?> get props => [message];
}

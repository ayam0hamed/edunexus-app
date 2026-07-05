import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:grad_project/features/video_call/data/services/webrtc_sfu_service.dart';
import 'package:grad_project/features/video_call/data/services/signalr_hub_service.dart';
import 'media_state.dart';

class MediaCubit extends Cubit<MediaState> {
  final WebrtcSfuService sfuService;
  final SignalrHubService hubService;

  MediaCubit({
    required this.sfuService,
    required this.hubService,
  }) : super(const MediaInitial());

  Future<void> initMedia() async {
    try {
      // 1. Request permissions
      final statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      if (statuses[Permission.camera] != PermissionStatus.granted ||
          statuses[Permission.microphone] != PermissionStatus.granted) {
        emit(const MediaError('Camera and Microphone permissions are required.'));
        return;
      }

      // 2. Initialize local MediaStream
      final localStream = await sfuService.startLocalStream();
      emit(MediaReady(
        localStream: localStream,
        isAudioOn: true,
        isVideoOn: true,
        isScreenSharing: false,
      ));
    } catch (e) {
      emit(MediaError('Failed to initialize local media tracks: $e'));
    }
  }

  Future<void> toggleAudio(String meetingId) async {
    final currentState = state;
    if (currentState is MediaReady) {
      final newAudioState = !currentState.isAudioOn;
      await sfuService.toggleLocalAudio(newAudioState);
      
      // Notify server via hub method
      try {
        await hubService.toggleAudio(meetingId, newAudioState);
      } catch (e) {
        debugPrint('MediaCubit: Hub toggleAudio failed: $e');
      }

      emit(currentState.copyWith(isAudioOn: newAudioState));
    }
  }

  Future<void> toggleVideo(String meetingId) async {
    final currentState = state;
    if (currentState is MediaReady) {
      final newVideoState = !currentState.isVideoOn;
      await sfuService.toggleLocalVideo(newVideoState);

      // Notify server via hub method
      try {
        await hubService.toggleVideo(meetingId, newVideoState);
      } catch (e) {
        debugPrint('MediaCubit: Hub toggleVideo failed: $e');
      }

      emit(currentState.copyWith(isVideoOn: newVideoState));
    }
  }

  Future<void> switchCamera() async {
    if (state is MediaReady) {
      await sfuService.switchCamera();
    }
  }

  Future<void> startScreenShare(String meetingId) async {
    final currentState = state;
    if (currentState is MediaReady) {
      try {
        // flutter_webrtc supports getDisplayMedia on some platforms
        // Standard WebRTC display media call
        // we'll update screen sharing state
        await hubService.startScreenSharing(meetingId);
        emit(currentState.copyWith(isScreenSharing: true));
      } catch (e) {
        debugPrint('MediaCubit: Screen share failed: $e');
      }
    }
  }

  Future<void> stopScreenShare(String meetingId) async {
    final currentState = state;
    if (currentState is MediaReady) {
      try {
        await hubService.stopScreenSharing(meetingId);
        emit(currentState.copyWith(isScreenSharing: false));
      } catch (e) {
        debugPrint('MediaCubit: Stop screen share failed: $e');
      }
    }
  }

  @override
  Future<void> close() async {
    await sfuService.stopLocalStream();
    return super.close();
  }
}

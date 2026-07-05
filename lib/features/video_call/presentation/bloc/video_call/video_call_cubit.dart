import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:grad_project/features/video_call/domain/repositories/video_call_repository.dart';
import 'package:grad_project/features/video_call/data/services/signalr_hub_service.dart';
import 'package:grad_project/features/video_call/data/services/webrtc_sfu_service.dart';
import 'video_call_state.dart';
import 'package:uuid/uuid.dart';

class VideoCallCubit extends Cubit<VideoCallState> {
  final VideoCallRepository repository;
  final SignalrHubService hubService;
  final WebrtcSfuService sfuService;

  VideoCallCubit({
    required this.repository,
    required this.hubService,
    required this.sfuService,
  }) : super(const VideoCallInitial());

  Future<void> createMeeting(String name, String userId, String userName) async {
    emit(const VideoCallLoading());
    try {
      final meeting = await repository.createMeeting(name, userId: userId, userName: userName);
      await joinMeeting(meeting.id, userName, isInstructor: true);
    } catch (e) {
      emit(VideoCallError('Failed to create meeting: $e'));
    }
  }

  Future<void> joinMeeting(String meetingId, String userName, {bool isInstructor = false}) async {
    emit(const VideoCallLoading());
    try {
      // Debug: confirm the exact backend meeting ID being used (Issue 7)
      debugPrint('[Meeting] Opening meeting: meetingId=$meetingId');

      await hubService.connect();

      final connectionId = hubService.connectionId ?? '';
      
      // 2. Perform REST Join API
      final joinResult = await repository.joinMeeting(meetingId, userName, connectionId);
      final participantId = joinResult['participantId']?.toString() ?? const Uuid().v4();

      // 3. Invoke Hub Join method
      await hubService.joinMeeting(meetingId, userName);

      // 4. Initialize Local Stream
      await sfuService.startLocalStream();

      // 5. Connect to SFU and setup WebRTC
      try {
        final sfuResponse = await repository.sfuJoin(meetingId, participantId);
        await sfuService.initializeSfu(sfuResponse, participantId, meetingId);
      } catch (e) {
        debugPrint('VideoCallCubit: SFU initialization failed, proceeding with fallback media: $e');
      }

      emit(VideoCallJoined(
        meetingId: meetingId,
        participantId: participantId,
        userName: userName,
        isInstructor: isInstructor,
      ));
    } catch (e) {
      emit(VideoCallError('Failed to join meeting: $e'));
    }
  }

  Future<void> leaveMeeting() async {
    final currentState = state;
    if (currentState is VideoCallJoined) {
      emit(const VideoCallLoading());
      try {
        final connectionId = hubService.connectionId ?? '';
        await repository.leaveMeeting(currentState.meetingId, currentState.participantId, connectionId);
        await hubService.leaveMeeting(currentState.meetingId);
      } catch (e) {
        debugPrint('VideoCallCubit: Error while leaving call: $e');
      } finally {
        await sfuService.dispose();
        await hubService.disconnect();
        emit(const VideoCallLeft());
      }
    }
  }

  Future<void> endMeeting() async {
    final currentState = state;
    if (currentState is VideoCallJoined && currentState.isInstructor) {
      emit(const VideoCallLoading());
      try {
        await repository.endMeeting(currentState.meetingId);
        await hubService.endMeeting(currentState.meetingId);
      } catch (e) {
        debugPrint('VideoCallCubit: Error while ending meeting: $e');
      } finally {
        await sfuService.dispose();
        await hubService.disconnect();
        emit(const VideoCallLeft());
      }
    }
  }
}

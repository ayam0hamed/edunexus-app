import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:grad_project/features/video_call/domain/repositories/video_call_repository.dart';
import 'package:grad_project/features/video_call/data/services/signalr_hub_service.dart';
import 'package:grad_project/features/video_call/data/services/webrtc_sfu_service.dart';
import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:grad_project/features/auth/data/services/jwt_service.dart';
import 'video_call_state.dart';

class VideoCallCubit extends Cubit<VideoCallState> {
  final VideoCallRepository repository;
  final SignalrHubService hubService;
  final WebrtcSfuService sfuService;
  final AuthRepository authRepository;
  final JwtService _jwtService = JwtService();

  VideoCallCubit({
    required this.repository,
    required this.hubService,
    required this.sfuService,
    required this.authRepository,
  }) : super(const VideoCallInitial());

  Future<void> createMeeting(
    String name,
    String userId,
    String userName,
    String userEmail,
  ) async {
    emit(const VideoCallLoading());
    try {
      await hubService.connect();
      final connectionId = hubService.connectionId ?? '';

      final meeting = await repository.createMeeting(
        name,
        userId: userId,
        userName: userName,
        connectionId: connectionId,
      );
      debugPrint(
        '[Meeting] Created meeting: meetingId=${meeting.id}, name=$name',
      );
      await joinMeeting(meeting.id, userEmail, isInstructor: true);
    } catch (e) {
      emit(VideoCallError('Failed to create meeting: $e'));
    }
  }

  Future<void> joinMeeting(
    String meetingId,
    String userName, {
    bool isInstructor = false,
  }) async {
    emit(const VideoCallLoading());
    try {
      debugPrint('[Meeting] Opening meeting: meetingId=$meetingId');

      // 1. Decode participantId from JWT BEFORE any network calls.
      //    The backend standardises on the `UserId` claim (a GUID) for all
      //    participant identity checks across SignalR hub and SFU server.
      final token = await authRepository.getToken();
      final participantId = _jwtService.getUserId(token ?? '');
      if (participantId == null || participantId.isEmpty) {
        throw Exception(
          'Cannot join meeting: UserId claim is missing from the JWT token. '
          'Please log out and log in again.',
        );
      }
      debugPrint('VideoCallCubit: participantId from JWT UserId claim = $participantId');

      // 2. Connect SignalR hub
      await hubService.connect();
      final connectionId = hubService.connectionId ?? '';

      // 3. Perform REST Join API – include participantId so the backend
      //    registers the correct GUID from the start.
      final joinResult = await repository.joinMeeting(
        meetingId,
        userName,
        connectionId,
        participantId: participantId,
      );

      // Now join the SignalR Hub group and trigger participant events
      await hubService.joinMeeting(meetingId, userName);

      debugPrint('========================');
      debugPrint('Join Response: $joinResult');
      debugPrint('ParticipantId = $participantId');
      debugPrint('MeetingId     = $meetingId');
      debugPrint('========================');

      // 4. Request camera & microphone permissions BEFORE getUserMedia().
      //    Without this the OS returns NotAllowedError (DOMException).
      final cameraStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();

      // If permanently denied, the OS won't show a dialog — send user to Settings.
      if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
        await openAppSettings();
        throw Exception(
          'Camera and microphone access is blocked. '
          'Please enable them in Settings → Apps → [App] → Permissions, then rejoin.',
        );
      }

      if (!cameraStatus.isGranted || !micStatus.isGranted) {
        throw Exception(
          'Camera and microphone permissions are required to join a meeting. '
          'Please tap "Allow" when prompted and try again.',
        );
      }

      // 5. Initialize Local Stream (hub join already handled by the REST call above,
      //    which passes connectionId so the backend automatically associates the
      //    SignalR connection with the meeting room.)
      await sfuService.startLocalStream();

      // 5. Connect to SFU and setup WebRTC
      try {
        final sfuResponse = await repository.sfuJoin(meetingId, participantId);
        await sfuService.initializeSfu(sfuResponse, participantId, meetingId);
      } catch (e) {
        debugPrint(
          'VideoCallCubit: SFU initialization failed, proceeding without SFU: $e',
        );
      }

      emit(
        VideoCallJoined(
          meetingId: meetingId,
          participantId: participantId,
          userName: userName,
          isInstructor: isInstructor,
        ),
      );
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
        await repository.leaveMeeting(
          currentState.meetingId,
          currentState.participantId,
          connectionId,
        );
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

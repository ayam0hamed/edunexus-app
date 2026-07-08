import 'package:grad_project/core/error/failures.dart';
import 'package:grad_project/core/error/exceptions.dart';
import 'package:grad_project/features/meetings/data/models/meeting_model.dart';
import 'package:grad_project/features/video_call/data/models/participant_model.dart';
import 'package:grad_project/features/video_call/data/models/ice_config_model.dart';
import 'package:grad_project/features/video_call/data/models/sfu_models.dart';
import 'package:grad_project/features/video_call/data/models/chat_message_model.dart';
import 'package:grad_project/features/video_call/data/services/video_call_api_service.dart';

class VideoCallRepository {
  final VideoCallApiService apiService;

  VideoCallRepository(this.apiService);

  Future<MeetingModel> createMeeting(String meetingName, {String userId = '', String userName = '', String connectionId = ''}) async {
    try {
      return await apiService.createMeeting(meetingName, userId: userId, userName: userName, connectionId: connectionId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  Future<Map<String, dynamic>> joinMeeting(
    String meetingId,
    String userName,
    String connectionId, {
    String participantId = '',
  }) async {
    try {
      return await apiService.joinMeeting(
        meetingId,
        userName,
        connectionId,
        participantId: participantId,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  Future<void> leaveMeeting(String meetingId, String participantId, String connectionId) async {
    try {
      await apiService.leaveMeeting(meetingId, participantId, connectionId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  Future<List<MeetingModel>> getActiveMeetings() async {
    try {
      return await apiService.getActiveMeetings();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  Future<MeetingModel> getMeeting(String meetingId) async {
    try {
      return await apiService.getMeeting(meetingId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  Future<void> endMeeting(String meetingId) async {
    try {
      await apiService.endMeeting(meetingId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  Future<List<ParticipantModel>> getMeetingParticipants(String meetingId) async {
    try {
      return await apiService.getMeetingParticipants(meetingId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  Future<IceConfigResponse> getIceConfig() async {
    try {
      return await apiService.getIceConfig();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  Future<SfuJoinResponse> sfuJoin(String meetingId, String participantId) async {
    try {
      return await apiService.sfuJoin(meetingId, participantId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  Future<void> sfuConnectRecv(
    String meetingId,
    String participantId,
    String transportId,
    Map<String, dynamic> dtlsParameters,
  ) async {
    try {
      await apiService.sfuConnectRecv(meetingId, participantId, transportId, dtlsParameters);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  Future<void> sfuCloseProducer(
    String meetingId,
    String participantId,
    String producerId,
  ) async {
    try {
      await apiService.sfuCloseProducer(meetingId, participantId, producerId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  Future<List<ProducerInfo>> getProducers(String meetingId) async {
    try {
      return await apiService.getProducers(meetingId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  Future<List<ChatMessageModel>> getChatHistory(String meetingId) async {
    try {
      return await apiService.getChatHistory(meetingId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}

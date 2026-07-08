import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:grad_project/core/network/dio_client.dart';
import 'package:grad_project/core/error/exceptions.dart';
import 'package:grad_project/features/meetings/data/models/meeting_model.dart';
import 'package:grad_project/features/video_call/config/api_config.dart';
import 'package:grad_project/features/video_call/data/models/participant_model.dart';
import 'package:grad_project/features/video_call/data/models/ice_config_model.dart';
import 'package:grad_project/features/video_call/data/models/sfu_models.dart';
import 'package:grad_project/features/video_call/data/models/chat_message_model.dart';
import 'package:grad_project/features/video_call/data/models/quiz_models.dart';

class VideoCallApiService {
  final DioClient dioClient;

  VideoCallApiService(this.dioClient);

  Future<MeetingModel> createMeeting(
    String meetingName, {
    String userId = '',
    String userName = '',
    String connectionId = '',
  }) async {
    try {
      final response = await dioClient.dio.post(
        VideoCallConfig.meetingsCreate,
        data: {
          'meetingName': meetingName,
          'userId': userId,
          'userName': userName,
          'connectionId': connectionId,
        },
      );
      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;

        final meetingJson = data['meeting'] as Map<String, dynamic>? ?? data;

        return MeetingModel.fromJson(meetingJson);
      }
      throw const ServerException('Empty response received');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ?? e.message ?? 'Failed to create meeting',
      );
    }
  }

  Future<Map<String, dynamic>> joinMeeting(
    String meetingId,
    String userName,
    String connectionId, {
    String participantId = '',
  }) async {
    try {
      final response = await dioClient.dio.post(
        VideoCallConfig.meetingsJoin(meetingId),
        data: {
          'userName': userName,
          'connectionId': connectionId,
          'participantId': participantId,
        },
      );
      debugPrint('Join meeting response: ${response.data}');
      return (response.data ?? <String, dynamic>{}) as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ?? e.message ?? 'Failed to join meeting',
      );
    }
  }

  Future<void> leaveMeeting(
    String meetingId,
    String participantId,
    String connectionId,
  ) async {
    try {
      await dioClient.dio.post(
        VideoCallConfig.meetingsLeave(meetingId),
        data: {'participantId': participantId, 'connectionId': connectionId},
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ?? e.message ?? 'Failed to leave meeting',
      );
    }
  }

  Future<List<MeetingModel>> getActiveMeetings() async {
    try {
      final response = await dioClient.dio.get(VideoCallConfig.meetingsActive);
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(MeetingModel.fromJson)
            .toList();
      }
      return const [];
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to load active meetings',
      );
    }
  }

  Future<MeetingModel> getMeeting(String meetingId) async {
    try {
      final response = await dioClient.dio.get(
        VideoCallConfig.meetingsById(meetingId),
      );
      return MeetingModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to load meeting details',
      );
    }
  }

  Future<void> endMeeting(String meetingId) async {
    try {
      await dioClient.dio.post(VideoCallConfig.meetingsEnd(meetingId));
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ?? e.message ?? 'Failed to end meeting',
      );
    }
  }

  Future<List<ParticipantModel>> getMeetingParticipants(
    String meetingId,
  ) async {
    try {
      final response = await dioClient.dio.get(
        VideoCallConfig.meetingsParticipants(meetingId),
      );
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ParticipantModel.fromJson)
            .toList();
      }
      return const [];
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to load meeting participants',
      );
    }
  }

  Future<void> toggleAudio(String connectionId, bool enabled) async {
    try {
      await dioClient.dio.post(
        VideoCallConfig.toggleAudio,
        data: {'connectionId': connectionId, 'enabled': enabled},
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to toggle audio status',
      );
    }
  }

  Future<void> toggleVideo(String connectionId, bool enabled) async {
    try {
      await dioClient.dio.post(
        VideoCallConfig.toggleVideo,
        data: {'connectionId': connectionId, 'enabled': enabled},
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to toggle video status',
      );
    }
  }

  Future<IceConfigResponse> getIceConfig() async {
    try {
      final response = await dioClient.dio.post(VideoCallConfig.iceConfig);
      return IceConfigResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to get WebRTC ICE configuration',
      );
    }
  }

  // ── SFU Endpoints ──────────────────────────────────────────────────────
  Future<SfuJoinResponse> sfuJoin(
    String meetingId,
    String participantId,
  ) async {
    try {
      final response = await dioClient.dio.post(
        VideoCallConfig.sfuJoin(meetingId),
        data: {'participantId': participantId},
      );
      return SfuJoinResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ?? e.message ?? 'Failed to join SFU room',
      );
    }
  }

  Future<void> sfuConnectSend(
    String meetingId,
    String participantId,
    String transportId,
    Map<String, dynamic> dtlsParameters,
  ) async {
    try {
      await dioClient.dio.post(
        VideoCallConfig.sfuConnectSend(meetingId),
        data: {
          'meetingId': meetingId,
          'participantId': participantId,
          'transportId': transportId,
          'dtlsParameters': dtlsParameters,
        },
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to connect send transport',
      );
    }
  }

  Future<void> sfuConnectRecv(
    String meetingId,
    String participantId,
    String transportId,
    Map<String, dynamic> dtlsParameters,
  ) async {
    try {
      await dioClient.dio.post(
        VideoCallConfig.sfuConnectRecv(meetingId),
        data: {
          'meetingId': meetingId,
          'participantId': participantId,
          'transportId': transportId,
          'dtlsParameters': dtlsParameters,
        },
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to connect recv transport',
      );
    }
  }

  Future<String> sfuProduce(
    String meetingId,
    String participantId,
    String kind,
    Map<String, dynamic> rtpParameters,
    Map<String, dynamic> appData,
  ) async {
    try {
      final response = await dioClient.dio.post(
        VideoCallConfig.sfuProduce(meetingId),
        data: {
          'meetingId': meetingId,
          'participantId': participantId,
          'kind': kind,
          'rtpParameters': rtpParameters,
          'appData': appData,
        },
      );
      return response.data['producerId']?.toString() ?? response.data['id']?.toString() ?? '';
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to produce tracks on SFU',
      );
    }
  }

  Future<Map<String, dynamic>> sfuConsume(
    String meetingId,
    String participantId,
    String producerId,
    Map<String, dynamic> rtpCapabilities,
  ) async {
    try {
      final response = await dioClient.dio.post(
        VideoCallConfig.sfuConsume(meetingId),
        data: {
          'participantId': participantId,
          'producerId': producerId,
          'rtpCapabilities': rtpCapabilities,
        },
      );
      final Map<String, dynamic> resData = (response.data ?? <String, dynamic>{}) as Map<String, dynamic>;
      if (resData.containsKey('consumer') && resData['consumer'] is Map) {
        return Map<String, dynamic>.from(resData['consumer'] as Map);
      }
      if (resData.containsKey('data') && resData['data'] is Map) {
        return Map<String, dynamic>.from(resData['data'] as Map);
      }
      return resData;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to consume tracks on SFU',
      );
    }
  }

  Future<void> sfuCloseProducer(
    String meetingId,
    String participantId,
    String producerId,
  ) async {
    try {
      await dioClient.dio.post(
        VideoCallConfig.sfuCloseProducer(meetingId),
        data: {'participantId': participantId, 'producerId': producerId},
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to close producer on SFU',
      );
    }
  }

  Future<List<ProducerInfo>> getProducers(String meetingId) async {
    try {
      final response = await dioClient.dio.get(
        VideoCallConfig.sfuProducers(meetingId),
      );
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ProducerInfo.fromJson)
            .toList();
      }
      return const [];
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to load active producers from SFU',
      );
    }
  }

  // ── Chat Endpoints ──────────────────────────────────────────────────────
  Future<List<ChatMessageModel>> getChatHistory(String meetingId) async {
    try {
      final response = await dioClient.dio.get(
        VideoCallConfig.chatHistory(meetingId),
      );
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ChatMessageModel.fromJson)
            .toList();
      }
      return const [];
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to load chat history',
      );
    }
  }

  // ── Quiz Endpoints ──────────────────────────────────────────────────────
  Future<String> createQuizSession(
    String meetingId,
    List<Map<String, dynamic>> questions,
  ) async {
    try {
      final response = await dioClient.dio.post(
        VideoCallConfig.quizCreate,
        data: {'meetingId': meetingId, 'questions': questions},
      );
      return response.data['sessionId']?.toString() ??
          response.data['id']?.toString() ??
          '';
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to create quiz session',
      );
    }
  }

  Future<QuizSessionModel> startQuiz(String sessionId) async {
    try {
      final response = await dioClient.dio.post(
        VideoCallConfig.quizStart(sessionId),
      );
      return QuizSessionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ?? e.message ?? 'Failed to start quiz',
      );
    }
  }

  Future<void> stopQuiz(String sessionId) async {
    try {
      await dioClient.dio.post(VideoCallConfig.quizStop(sessionId));
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ?? e.message ?? 'Failed to stop quiz',
      );
    }
  }

  Future<bool> answerQuizQuestion(
    String questionId,
    String selectedOption,
  ) async {
    try {
      final response = await dioClient.dio.post(
        VideoCallConfig.quizAnswer,
        data: {'questionId': questionId, 'selectedOption': selectedOption},
      );
      return response.data['isCorrect'] as bool? ?? false;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to submit quiz answer',
      );
    }
  }

  Future<Map<String, dynamic>> getQuizResults(String sessionId) async {
    try {
      final response = await dioClient.dio.get(
        VideoCallConfig.quizResults(sessionId),
      );
      return (response.data ?? <String, dynamic>{}) as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to load quiz results',
      );
    }
  }
}

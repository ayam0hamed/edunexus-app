import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:grad_project/features/auth/data/services/jwt_service.dart';
import 'package:grad_project/features/video_call/config/api_config.dart';
import 'package:grad_project/features/video_call/data/models/chat_message_model.dart';
import 'package:grad_project/features/video_call/data/models/quiz_models.dart';
import 'package:grad_project/features/video_call/data/models/signalr_payloads.dart';

class SignalrHubService {
  final AuthRepository authRepository;
  HubConnection? _hubConnection;
  
  String? _currentMeetingId;
  String? _currentEmail;

  // StreamControllers for client events
  final _participantJoinedCtrl = StreamController<ParticipantJoinedPayload>.broadcast();
  final _participantLeftCtrl = StreamController<String>.broadcast();
  final _existingParticipantsCtrl = StreamController<List<ParticipantJoinedPayload>>.broadcast();
  final _participantAudioToggledCtrl = StreamController<MediaTogglePayload>.broadcast();
  final _participantVideoToggledCtrl = StreamController<MediaTogglePayload>.broadcast();
  final _screenSharingStartedCtrl = StreamController<String>.broadcast();
  final _screenSharingStoppedCtrl = StreamController<String>.broadcast();
  final _userScreenSharingCtrl = StreamController<Map<String, dynamic>>.broadcast();
  final _participantHandRaisedCtrl = StreamController<HandRaisedPayload>.broadcast();
  final _participantReactionCtrl = StreamController<ReactionPayload>.broadcast();
  final _participantKickedCtrl = StreamController<KickedPayload>.broadcast();
  final _youWereKickedCtrl = StreamController<String>.broadcast();
  final _allParticipantsMutedCtrl = StreamController<String>.broadcast();
  final _meetingEndedCtrl = StreamController<String>.broadcast();
  final _meetingLockToggledCtrl = StreamController<LockTogglePayload>.broadcast();
  final _chatToggledCtrl = StreamController<ChatTogglePayload>.broadcast();
  final _receiveChatMessageCtrl = StreamController<ChatMessageModel>.broadcast();
  final _quizStartedCtrl = StreamController<QuizSessionModel>.broadcast();
  final _quizEndedCtrl = StreamController<String>.broadcast();
  final _quizResultsUpdatedCtrl = StreamController<dynamic>.broadcast();
  final _sfuProducerCreatedCtrl = StreamController<ProducerCreatedPayload>.broadcast();
  final _sfuProducerClosedCtrl = StreamController<ProducerClosedPayload>.broadcast();

  SignalrHubService(this.authRepository);

  // Getters for streams
  Stream<ParticipantJoinedPayload> get participantJoinedStream => _participantJoinedCtrl.stream;
  Stream<String> get participantLeftStream => _participantLeftCtrl.stream;
  Stream<List<ParticipantJoinedPayload>> get existingParticipantsStream => _existingParticipantsCtrl.stream;
  Stream<MediaTogglePayload> get participantAudioToggledStream => _participantAudioToggledCtrl.stream;
  Stream<MediaTogglePayload> get participantVideoToggledStream => _participantVideoToggledCtrl.stream;
  Stream<String> get screenSharingStartedStream => _screenSharingStartedCtrl.stream;
  Stream<String> get screenSharingStoppedStream => _screenSharingStoppedCtrl.stream;
  Stream<Map<String, dynamic>> get userScreenSharingStream => _userScreenSharingCtrl.stream;
  Stream<HandRaisedPayload> get participantHandRaisedStream => _participantHandRaisedCtrl.stream;
  Stream<ReactionPayload> get participantReactionStream => _participantReactionCtrl.stream;
  Stream<KickedPayload> get participantKickedStream => _participantKickedCtrl.stream;
  Stream<String> get youWereKickedStream => _youWereKickedCtrl.stream;
  Stream<String> get allParticipantsMutedStream => _allParticipantsMutedCtrl.stream;
  Stream<String> get meetingEndedStream => _meetingEndedCtrl.stream;
  Stream<LockTogglePayload> get meetingLockToggledStream => _meetingLockToggledCtrl.stream;
  Stream<ChatTogglePayload> get chatToggledStream => _chatToggledCtrl.stream;
  Stream<ChatMessageModel> get receiveChatMessageStream => _receiveChatMessageCtrl.stream;
  Stream<QuizSessionModel> get quizStartedStream => _quizStartedCtrl.stream;
  Stream<String> get quizEndedStream => _quizEndedCtrl.stream;
  Stream<dynamic> get quizResultsUpdatedStream => _quizResultsUpdatedCtrl.stream;
  Stream<ProducerCreatedPayload> get sfuProducerCreatedStream => _sfuProducerCreatedCtrl.stream;
  Stream<ProducerClosedPayload> get sfuProducerClosedStream => _sfuProducerClosedCtrl.stream;

  String? get connectionId => _hubConnection?.connectionId;

  Future<void> connect() async {
    if (_hubConnection != null && _hubConnection!.state == HubConnectionState.Connected) {
      debugPrint('SignalrHubService: Already connected');
      return;
    }

    try {
      debugPrint('SignalrHubService: Connecting to ${VideoCallConfig.signalrHubUrl}');
      
      _hubConnection = HubConnectionBuilder()
          .withUrl(
            VideoCallConfig.signalrHubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async {
                final token = await authRepository.getToken();
                return token ?? '';
              },
            ),
          )
          .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, 30000])
          .build();

      _registerHubCallbacks();

      await _hubConnection!.start();
      debugPrint('SignalrHubService: Connected successfully. ID: ${_hubConnection!.connectionId}');
    } catch (e) {
      debugPrint('SignalrHubService: Failed to connect to SignalR: $e');
      rethrow;
    }
  }

  void _registerHubCallbacks() {
    if (_hubConnection == null) return;

    _hubConnection!.on('MeetingJoined', (args) {
      debugPrint('SignalrHubService: MeetingJoined event received: $args');
    });

    _hubConnection!.on('ParticipantJoined', (args) {
      if (args != null && args.isNotEmpty) {
        final payload = ParticipantJoinedPayload.fromJson(args[0] as Map<String, dynamic>);
        _participantJoinedCtrl.add(payload);
      }
    });

    _hubConnection!.on('ParticipantLeft', (args) {
      if (args != null && args.isNotEmpty) {
        _participantLeftCtrl.add(args[0].toString());
      }
    });

    _hubConnection!.on('ExistingParticipants', (args) {
      if (args != null && args.isNotEmpty && args[0] is List) {
        final list = (args[0] as List)
            .whereType<Map<String, dynamic>>()
            .map(ParticipantJoinedPayload.fromJson)
            .toList();
        _existingParticipantsCtrl.add(list);
      }
    });

    _hubConnection!.on('ParticipantAudioToggled', (args) {
      if (args != null && args.isNotEmpty) {
        final payload = MediaTogglePayload.fromJson(args[0] as Map<String, dynamic>);
        _participantAudioToggledCtrl.add(payload);
      }
    });

    _hubConnection!.on('ParticipantVideoToggled', (args) {
      if (args != null && args.isNotEmpty) {
        final payload = MediaTogglePayload.fromJson(args[0] as Map<String, dynamic>);
        _participantVideoToggledCtrl.add(payload);
      }
    });

    _hubConnection!.on('ScreenSharingStarted', (args) {
      if (args != null && args.isNotEmpty) {
        _screenSharingStartedCtrl.add(args[0].toString());
      }
    });

    _hubConnection!.on('ScreenSharingStopped', (args) {
      if (args != null && args.isNotEmpty) {
        _screenSharingStoppedCtrl.add(args[0].toString());
      }
    });

    _hubConnection!.on('UserScreenSharing', (args) {
      if (args != null && args.isNotEmpty) {
        _userScreenSharingCtrl.add(args[0] as Map<String, dynamic>);
      }
    });

    _hubConnection!.on('ParticipantHandRaised', (args) => _onHandRaised(args));
    _hubConnection!.on('RaiseHand', (args) => _onHandRaised(args));

    _hubConnection!.on('ParticipantReaction', (args) => _onReactionReceived(args));
    _hubConnection!.on('ReactionReceived', (args) => _onReactionReceived(args));

    _hubConnection!.on('ParticipantKicked', (args) {
      if (args != null && args.isNotEmpty) {
        final payload = KickedPayload.fromJson(args[0] as Map<String, dynamic>);
        _participantKickedCtrl.add(payload);
      }
    });

    _hubConnection!.on('YouWereKicked', (args) {
      if (args != null && args.isNotEmpty) {
        _youWereKickedCtrl.add(args[0].toString());
      }
    });

    _hubConnection!.on('AllParticipantsMuted', (args) {
      if (args != null && args.isNotEmpty) {
        _allParticipantsMutedCtrl.add(args[0].toString());
      }
    });

    _hubConnection!.on('MeetingEnded', (args) {
      if (args != null && args.isNotEmpty) {
        _meetingEndedCtrl.add(args[0].toString());
      }
    });

    _hubConnection!.on('MeetingLockToggled', (args) {
      if (args != null && args.isNotEmpty) {
        final payload = LockTogglePayload.fromJson(args[0] as Map<String, dynamic>);
        _meetingLockToggledCtrl.add(payload);
      }
    });

    _hubConnection!.on('ChatToggled', (args) {
      if (args != null && args.isNotEmpty) {
        final payload = ChatTogglePayload.fromJson(args[0] as Map<String, dynamic>);
        _chatToggledCtrl.add(payload);
      }
    });

    _hubConnection!.on('ReceiveChatMessage', (args) => _onMessageReceived(args));
    _hubConnection!.on('MessageReceived', (args) => _onMessageReceived(args));
    _hubConnection!.on('ReceiveMessage', (args) => _onMessageReceived(args));

    _hubConnection!.on('QuizStarted', (args) {
      if (args != null && args.isNotEmpty) {
        final payload = QuizSessionModel.fromJson(args[0] as Map<String, dynamic>);
        _quizStartedCtrl.add(payload);
      }
    });

    _hubConnection!.on('QuizEnded', (args) {
      if (args != null && args.isNotEmpty) {
        _quizEndedCtrl.add(args[0].toString());
      }
    });

    _hubConnection!.on('QuizResultsUpdated', (args) {
      if (args != null && args.isNotEmpty) {
        _quizResultsUpdatedCtrl.add(args[0]);
      }
    });

    _hubConnection!.on('SfuProducerCreated', (args) => _onProducerCreated(args));
    _hubConnection!.on('ProducerCreated', (args) => _onProducerCreated(args));

    _hubConnection!.on('SfuProducerClosed', (args) => _onProducerClosed(args));
    _hubConnection!.on('ProducerClosed', (args) => _onProducerClosed(args));
  }

  void _onHandRaised(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final payload = HandRaisedPayload.fromJson(args[0] as Map<String, dynamic>);
      _participantHandRaisedCtrl.add(payload);
    }
  }

  void _onReactionReceived(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final payload = ReactionPayload.fromJson(args[0] as Map<String, dynamic>);
      _participantReactionCtrl.add(payload);
    }
  }

  void _onMessageReceived(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final payload = ChatMessageModel.fromJson(args[0] as Map<String, dynamic>);
      _receiveChatMessageCtrl.add(payload);
    }
  }

  void _onProducerCreated(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final payload = ProducerCreatedPayload.fromJson(args[0] as Map<String, dynamic>);
      _sfuProducerCreatedCtrl.add(payload);
    }
  }

  void _onProducerClosed(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final payload = ProducerClosedPayload.fromJson(args[0] as Map<String, dynamic>);
      _sfuProducerClosedCtrl.add(payload);
    }
  }

  // Hub Invoke Methods
  Future<void> joinMeeting(String meetingId, String userName) async {
    _currentMeetingId = meetingId;
    _currentEmail = userName;
    await _invoke('JoinMeeting', [meetingId, userName]);
  }

  Future<void> leaveMeeting(String meetingId) async {
    await _invoke('LeaveMeeting', []);
  }

  Future<void> sendChatMessage(String meetingId, String content) async {
    debugPrint('=== CHAT SEND ===');
    await _invoke('SendChatMessage', [content]);
  }

  Future<void> raiseHand(String meetingId, bool raised) async {
    await _invoke('RaiseHand', [raised]);
  }

  Future<void> sendReaction(String meetingId, String emoji) async {
    debugPrint('=== REACTION SEND ===');
    await _invoke('SendReaction', [emoji]);
  }

  Future<void> toggleAudio(String meetingId, bool enabled) async {
    await _invoke('ToggleAudio', [enabled]);
  }

  Future<void> toggleVideo(String meetingId, bool enabled) async {
    await _invoke('ToggleVideo', [enabled]);
  }

  Future<void> startScreenSharing(String meetingId) async {
    await _invoke('StartScreenSharing', []);
  }

  Future<void> stopScreenSharing(String meetingId) async {
    await _invoke('StopScreenSharing', []);
  }

  Future<void> muteAllParticipants(String meetingId) async {
    await _invoke('MuteAllParticipants', []);
  }

  Future<void> kickParticipant(String meetingId, String participantId) async {
    await _invoke('KickParticipant', [participantId]);
  }

  Future<void> endMeeting(String meetingId) async {
    await _invoke('EndMeeting', []);
  }

  Future<void> lockMeeting(String meetingId, bool locked) async {
    await _invoke('LockMeeting', [locked]);
  }

  Future<void> toggleChat(String meetingId, bool enabled) async {
    await _invoke('ToggleChat', [enabled]);
  }

  Future<void> notifyProducerCreated(String meetingId, String producerId, String kind, Map<String, dynamic> appData) async {
    await _invoke('NotifyProducerCreated', [producerId, kind, appData]);
  }

  Future<void> notifyProducerClosed(String meetingId, String producerId, String kind, Map<String, dynamic> appData) async {
    await _invoke('NotifyProducerClosed', [producerId, kind, appData]);
  }

  Future<dynamic> _invoke(String methodName, List<Object> args) async {
    final token = await authRepository.getToken();
    final userId = token != null && token.isNotEmpty 
        ? (JwtService().getUserId(token) ?? '') 
        : '';

    debugPrint('MEETING ID     : $_currentMeetingId');
    debugPrint('USER ID        : $userId');
    debugPrint('PARTICIPANT ID : $userId');
    debugPrint('EMAIL          : $_currentEmail');
    debugPrint('HUB METHOD NAME: $methodName');
    debugPrint('PAYLOAD        : $args');

    if (_hubConnection == null || _hubConnection!.state != HubConnectionState.Connected) {
      final exc = Exception('SignalR connection is not established');
      debugPrint('=== SIGNALR INVOKE FAILURE ===');
      debugPrint('HUB METHOD NAME: $methodName');
      debugPrint('ERROR          : $exc');
      throw exc;
    }

    try {
      final response = await _hubConnection!.invoke(methodName, args: args);
      debugPrint('=== SIGNALR INVOKE SUCCESS ===');
      debugPrint('HUB METHOD NAME: $methodName');
      debugPrint('RESPONSE       : $response');
      return response;
    } catch (e, s) {
      debugPrint('=== SIGNALR INVOKE FAILURE ===');
      debugPrint('HUB METHOD NAME: $methodName');
      debugPrint('ERROR          : $e');
      debugPrint('STACKTRACE     : $s');
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (_hubConnection != null) {
      await _hubConnection!.stop();
      _hubConnection = null;
      debugPrint('SignalrHubService: Disconnected');
    }
  }
}

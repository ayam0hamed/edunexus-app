import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/mediasoup_client_flutter.dart';
import 'package:grad_project/features/video_call/data/models/sfu_models.dart';
import 'package:grad_project/features/video_call/data/services/video_call_api_service.dart';

class WebrtcSfuService {
  final VideoCallApiService apiService;

  Device? _mediasoupDevice;
  Transport? _sendTransport;
  Transport? _recvTransport;

  Producer? _audioProducer;
  Producer? _videoProducer;

  MediaStream? _localStream;
  final Map<String, MediaStream> _remoteStreams = {};
  final Map<String, Consumer> _consumers = {};

  /// Stored so MediaCubit can pass it when consuming late-joining producers.
  String? currentMeetingId;

  final _remoteStreamsController = StreamController<Map<String, MediaStream>>.broadcast();

  WebrtcSfuService(this.apiService);

  MediaStream? get localStream => _localStream;
  Map<String, MediaStream> get remoteStreams => _remoteStreams;
  Stream<Map<String, MediaStream>> get remoteStreamsStream => _remoteStreamsController.stream;

  Future<MediaStream> startLocalStream() async {
    if (_localStream != null) return _localStream!;

    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth': '640',
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    try {
      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      debugPrint('WebrtcSfuService: Local MediaStream started successfully');
      return _localStream!;
    } catch (e) {
      debugPrint('WebrtcSfuService: Error getting local stream: $e');
      rethrow;
    }
  }

  Future<void> stopLocalStream() async {
    if (_localStream != null) {
      for (var track in _localStream!.getTracks()) {
        await track.stop();
      }
      await _localStream!.dispose();
      _localStream = null;
      debugPrint('WebrtcSfuService: Local MediaStream stopped');
    }
  }

  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().firstOrNull;
      if (videoTrack != null) {
        await Helper.switchCamera(videoTrack);
        debugPrint('WebrtcSfuService: Switched camera source');
      }
    }
  }

  Future<void> toggleLocalAudio(bool enabled) async {
    if (_localStream != null) {
      for (var track in _localStream!.getAudioTracks()) {
        track.enabled = enabled;
      }
      // Pause/resume the Mediasoup producer so the SFU stops forwarding
      // audio RTP to remote consumers when muted.
      if (enabled) {
        _audioProducer?.resume();
      } else {
        _audioProducer?.pause();
      }
      debugPrint('WebrtcSfuService: Local audio toggled to $enabled');
    }
  }

  Future<void> toggleLocalVideo(bool enabled) async {
    if (_localStream != null) {
      for (var track in _localStream!.getVideoTracks()) {
        track.enabled = enabled;
      }
      // Pause/resume the Mediasoup producer so the SFU stops forwarding
      // video RTP to remote consumers when camera is off.
      if (enabled) {
        _videoProducer?.resume();
      } else {
        _videoProducer?.pause();
      }
      debugPrint('WebrtcSfuService: Local video toggled to $enabled');
    }
  }

  Future<void> initializeSfu(SfuJoinResponse sfuJoinResponse, String participantId, String meetingId) async {
    currentMeetingId = meetingId;
    try {
      _mediasoupDevice = Device();
      final routerRtpCapabilities = RtpCapabilities.fromMap(sfuJoinResponse.rtpCapabilities);
      await _mediasoupDevice!.load(routerRtpCapabilities: routerRtpCapabilities);

      _sendTransport = _mediasoupDevice!.createSendTransportFromMap(
        sfuJoinResponse.sendTransport.toJson(),
        producerCallback: (Producer producer) {
          if (producer.source == 'mic') {
            _audioProducer = producer;
          } else if (producer.source == 'cam') {
            _videoProducer = producer;
          }
        },
      );

      _sendTransport!.on('connect', (Map data) {
        apiService.sfuConnectSend(
          meetingId,
          participantId,
          _sendTransport!.id,
          data['dtlsParameters'],
        ).then((_) {
          data['callback']();
        }).catchError((e) {
          data['errback'](e);
        });
      });

      _sendTransport!.on('produce', (Map data) {
        apiService.sfuProduce(
          meetingId,
          participantId,
          data['kind'],
          data['rtpParameters'],
          data['appData'],
        ).then((producerId) {
          data['callback'](producerId);
        }).catchError((e) {
          data['errback'](e);
        });
      });

      _recvTransport = _mediasoupDevice!.createRecvTransportFromMap(
        sfuJoinResponse.recvTransport.toJson(),
        consumerCallback: (Consumer consumer, [dynamic accept]) async {
          _consumers[consumer.producerId] = consumer;

          final pId = consumer.appData['participantId']?.toString() ?? 'remote-${consumer.producerId}';
          
          MediaStream stream;
          if (_remoteStreams.containsKey(pId)) {
            stream = _remoteStreams[pId]!;
            await stream.addTrack(consumer.track);
          } else {
            stream = await createLocalMediaStream('stream-$pId');
            await stream.addTrack(consumer.track);
            _remoteStreams[pId] = stream;
          }
          
          _remoteStreamsController.add(Map.from(_remoteStreams));
          
          if (accept != null) {
            accept();
          }
        },
      );

      _recvTransport!.on('connect', (Map data) {
        apiService.sfuConnectSend(
          meetingId,
          participantId,
          _recvTransport!.id,
          data['dtlsParameters'],
        ).then((_) {
          data['callback']();
        }).catchError((e) {
          data['errback'](e);
        });
      });

      if (_localStream != null) {
        if (_localStream!.getAudioTracks().isNotEmpty) {
          _sendTransport!.produce(
            track: _localStream!.getAudioTracks().first,
            stream: _localStream!,
            source: 'mic',
            appData: {'type': 'mic'},
          );
        }
        if (_localStream!.getVideoTracks().isNotEmpty) {
          _sendTransport!.produce(
            track: _localStream!.getVideoTracks().first,
            stream: _localStream!,
            source: 'cam',
            appData: {'type': 'cam'},
          );
        }
      }

      for (var producer in sfuJoinResponse.existingProducers) {
        await consumeRemoteProducer(meetingId, participantId, producer.producerId);
      }
    } catch (e) {
      debugPrint('WebrtcSfuService: Error initializing SFU: $e');
    }
  }

  Future<void> consumeRemoteProducer(String meetingId, String participantId, String producerId) async {
    try {
      final consumerData = await apiService.sfuConsume(
        meetingId,
        participantId,
        producerId,
        _mediasoupDevice!.rtpCapabilities.toMap(),
      );

      _recvTransport!.consume(
        id: consumerData['id'],
        producerId: consumerData['producerId'],
        peerId: consumerData['appData']?['participantId']?.toString() ?? producerId,
        kind: consumerData['kind'] == 'audio' ? RTCRtpMediaType.RTCRtpMediaTypeAudio : RTCRtpMediaType.RTCRtpMediaTypeVideo,
        rtpParameters: RtpParameters.fromMap(consumerData['rtpParameters']),
        appData: Map<String, dynamic>.from(consumerData['appData'] ?? {}),
      );
    } catch (e) {
      debugPrint('WebrtcSfuService: Failed to consume remote producer $producerId: $e');
    }
  }

  Future<void> closeProducer(String kind) async {
    // Implement endpoint notification/cleanups if needed
  }

  Future<void> closeConsumer(String producerId) async {
    final consumer = _consumers.remove(producerId);
    if (consumer != null) {
      await consumer.close();
    }
  }

  Future<void> dispose() async {
    await stopLocalStream();
    
    for (var stream in _remoteStreams.values) {
      await stream.dispose();
    }
    _remoteStreams.clear();
    _remoteStreamsController.add(const {});

    for (var consumer in _consumers.values) {
      await consumer.close();
    }
    _consumers.clear();

    _audioProducer?.close();
    _videoProducer?.close();
    
    _sendTransport?.close();
    _recvTransport?.close();

    debugPrint('WebrtcSfuService: All WebRTC/SFU connections disposed');
  }
}

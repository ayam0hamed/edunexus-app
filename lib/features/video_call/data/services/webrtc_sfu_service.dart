import 'dart:async';
import 'package:flutter/foundation.dart';
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
  String? currentParticipantId;

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
      final audioTrack = _localStream!.getAudioTracks().firstOrNull;
      if (audioTrack != null) {
        audioTrack.enabled = enabled;
      }
      
      if (enabled) {
        if (_audioProducer == null && _sendTransport != null && audioTrack != null) {
          _sendTransport!.produce(
            track: audioTrack,
            stream: _localStream!,
            source: 'mic',
            appData: {
              'type': 'mic',
              'participantId': currentParticipantId,
            },
          );
        } else {
          _audioProducer?.resume();
        }
      } else {
        if (_audioProducer != null) {
          final pId = _audioProducer!.id;
          _audioProducer!.close();
          _audioProducer = null;
          if (currentMeetingId != null && currentParticipantId != null) {
            try {
              await apiService.sfuCloseProducer(currentMeetingId!, currentParticipantId!, pId);
            } catch (e) {
              debugPrint('WebrtcSfuService: Failed to close audio producer on backend: $e');
            }
          }
        }
      }
      debugPrint('WebrtcSfuService: Local audio toggled to $enabled');
    }
  }

  Future<void> toggleLocalVideo(bool enabled) async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().firstOrNull;
      if (videoTrack != null) {
        videoTrack.enabled = enabled;
      }
      
      if (enabled) {
        if (_videoProducer == null && _sendTransport != null && videoTrack != null) {
          _sendTransport!.produce(
            track: videoTrack,
            stream: _localStream!,
            source: 'cam',
            appData: {
              'type': 'cam',
              'participantId': currentParticipantId,
            },
          );
        } else {
          _videoProducer?.resume();
        }
      } else {
        if (_videoProducer != null) {
          final pId = _videoProducer!.id;
          _videoProducer!.close();
          _videoProducer = null;
          if (currentMeetingId != null && currentParticipantId != null) {
            try {
              await apiService.sfuCloseProducer(currentMeetingId!, currentParticipantId!, pId);
            } catch (e) {
              debugPrint('WebrtcSfuService: Failed to close video producer on backend: $e');
            }
          }
        }
      }
      debugPrint('WebrtcSfuService: Local video toggled to $enabled');
    }
  }

  Future<void> initializeSfu(SfuJoinResponse sfuJoinResponse, String participantId, String meetingId) async {
    currentMeetingId = meetingId;
    currentParticipantId = participantId;
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

          final pId = (consumer.appData['participantId']?.toString() ?? 'remote-${consumer.producerId}').toLowerCase();
          
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
        apiService.sfuConnectRecv(
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
            appData: {
              'type': 'mic',
              'participantId': participantId,
            },
          );
        }
        if (_localStream!.getVideoTracks().isNotEmpty) {
          _sendTransport!.produce(
            track: _localStream!.getVideoTracks().first,
            stream: _localStream!,
            source: 'cam',
            appData: {
              'type': 'cam',
              'participantId': participantId,
            },
          );
        }
      }

      // Fetch active producers from the endpoint
      try {
        final producers = await apiService.getProducers(meetingId);
        for (var producer in producers) {
          if (producer.participantId.toLowerCase() != participantId.toLowerCase()) {
            await consumeRemoteProducer(
              meetingId,
              participantId,
              producer.producerId,
              remoteParticipantId: producer.participantId,
            );
          }
        }
      } catch (e) {
        debugPrint('WebrtcSfuService: Failed to load/consume existing producers: $e');
      }
    } catch (e) {
      debugPrint('WebrtcSfuService: Error initializing SFU: $e');
    }
  }

  Future<void> consumeRemoteProducer(
    String meetingId,
    String localParticipantId,
    String producerId, {
    String? remoteParticipantId,
  }) async {
    try {
      final consumerData = await apiService.sfuConsume(
        meetingId,
        localParticipantId,
        producerId,
        _mediasoupDevice!.rtpCapabilities.toMap(),
      );

      final String actualPeerId = remoteParticipantId ??
          consumerData['appData']?['participantId']?.toString() ??
          producerId;

      final Map<String, dynamic> mergedAppData = {
        'participantId': actualPeerId,
        ...Map<String, dynamic>.from(consumerData['appData'] ?? {}),
      };

      _recvTransport!.consume(
        id: consumerData['id'],
        producerId: consumerData['producerId'],
        peerId: actualPeerId,
        kind: consumerData['kind'] == 'audio'
            ? RTCRtpMediaType.RTCRtpMediaTypeAudio
            : RTCRtpMediaType.RTCRtpMediaTypeVideo,
        rtpParameters: RtpParameters.fromMap(consumerData['rtpParameters']),
        appData: mergedAppData,
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
      final pId = (consumer.appData['participantId']?.toString() ?? '').toLowerCase();
      await consumer.close();
      if (pId.isNotEmpty && _remoteStreams.containsKey(pId)) {
        final stream = _remoteStreams[pId]!;
        final track = consumer.track;
        await stream.removeTrack(track);
        if (stream.getTracks().isEmpty) {
          _remoteStreams.remove(pId);
          await stream.dispose();
        }
        _remoteStreamsController.add(Map.from(_remoteStreams));
      }
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

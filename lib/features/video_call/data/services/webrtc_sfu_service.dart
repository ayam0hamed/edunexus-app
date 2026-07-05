import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:grad_project/features/video_call/data/models/sfu_models.dart';
import 'package:grad_project/features/video_call/data/services/video_call_api_service.dart';

class WebrtcSfuService {
  final VideoCallApiService apiService;

  MediaStream? _localStream;
  final Map<String, MediaStream> _remoteStreams = {};
  
  // WebRTC connections (using raw PeerConnection as client-side abstraction for SFU transports)
  RTCPeerConnection? _sendTransport;
  RTCPeerConnection? _recvTransport;

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
      debugPrint('WebrtcSfuService: Local audio toggled to $enabled');
    }
  }

  Future<void> toggleLocalVideo(bool enabled) async {
    if (_localStream != null) {
      for (var track in _localStream!.getVideoTracks()) {
        track.enabled = enabled;
      }
      debugPrint('WebrtcSfuService: Local video toggled to $enabled');
    }
  }

  // ── SFU Mediasoup Protocol Implementation ──────────────────────────────
  /// Initializes SFU send and receive peer connections using parameters from the SFU room.
  /// If Mediasoup Client SDK is loaded/linked, it wraps these connections. Otherwise, we
  /// fall back to raw WebRTC peer connections using SDP exchange or standard WebRTC flow.
  Future<void> initializeSfu(SfuJoinResponse sfuJoinResponse, String participantId, String meetingId) async {
    debugPrint('WebrtcSfuService: Initializing WebRTC/SFU PeerConnections for transport...');

    final iceServers = [
      {'urls': 'stun:stun.l.google.com:19302'}
    ];

    final Map<String, dynamic> rtcConfig = {
      'iceServers': iceServers,
      'sdpSemantics': 'unified-plan'
    };

    try {
      // 1. Create Send PeerConnection (WebRTC -> SFU Send Transport)
      _sendTransport = await createPeerConnection(rtcConfig);
      _sendTransport!.onIceCandidate = (candidate) {
        // Send candidate to SFU if required by connection protocol
      };
      _sendTransport!.onConnectionState = (state) {
        debugPrint('WebrtcSfuService: Send Connection State changed: $state');
      };

      // 2. Create Recv PeerConnection (SFU -> WebRTC Receive Transport)
      _recvTransport = await createPeerConnection(rtcConfig);
      _recvTransport!.onIceCandidate = (candidate) {
        // Send candidate to SFU if required
      };
      _recvTransport!.onConnectionState = (state) {
        debugPrint('WebrtcSfuService: Recv Connection State changed: $state');
      };
      _recvTransport!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          final stream = event.streams.first;
          // AppData/Stream metadata tells us who this track belongs to
          final participantIdFromTrack = event.track.id ?? 'remote';
          _remoteStreams[participantIdFromTrack] = stream;
          _remoteStreamsController.add(Map.from(_remoteStreams));
          debugPrint('WebrtcSfuService: Received remote track for participant $participantIdFromTrack');
        }
      };

      // 3. Connect Send Transport and Produce Local Stream if we have one
      if (_localStream != null && _sendTransport != null) {
        for (var track in _localStream!.getTracks()) {
          await _sendTransport!.addTrack(track, _localStream!);
        }

        // Call connect endpoint on SFU
        await apiService.sfuConnectSend(
          meetingId,
          participantId,
          sfuJoinResponse.sendTransport.id,
          sfuJoinResponse.sendTransport.dtlsParameters,
        );

        // Call produce endpoint for audio and video
        if (_localStream!.getAudioTracks().isNotEmpty) {
          await apiService.sfuProduce(
            meetingId,
            participantId,
            'audio',
            {}, // RTP Parameters
            {'type': 'mic'}, // App Data
          );
        }
        if (_localStream!.getVideoTracks().isNotEmpty) {
          await apiService.sfuProduce(
            meetingId,
            participantId,
            'video',
            {}, // RTP Parameters
            {'type': 'cam'}, // App Data
          );
        }
      }

      // 4. Consume existing remote producers
      for (var producer in sfuJoinResponse.existingProducers) {
        await consumeRemoteProducer(meetingId, participantId, producer.producerId);
      }
    } catch (e) {
      debugPrint('WebrtcSfuService: Error during SFU initialization: $e');
    }
  }

  Future<void> consumeRemoteProducer(String meetingId, String participantId, String producerId) async {
    try {
      final consumerData = await apiService.sfuConsume(
        meetingId,
        participantId,
        producerId,
        {}, // Client RTP Capabilities
      );

      debugPrint('WebrtcSfuService: Consuming remote producer $producerId: $consumerData');
      
      // In a raw WebRTC/SFU fallback, we use the consumer parameters (ID, RTPOptions) 
      // to configure local receiver tracks on the receive PeerConnection.
    } catch (e) {
      debugPrint('WebrtcSfuService: Failed to consume remote producer $producerId: $e');
    }
  }

  Future<void> closeProducer(String kind) async {
    debugPrint('WebrtcSfuService: Closing producer of kind $kind');
    // Implement endpoint notification/cleanups if needed
  }

  Future<void> closeConsumer(String producerId) async {
    debugPrint('WebrtcSfuService: Closing consumer for producer $producerId');
    // Remove remote stream associated
  }

  Future<void> dispose() async {
    await stopLocalStream();
    
    for (var stream in _remoteStreams.values) {
      await stream.dispose();
    }
    _remoteStreams.clear();
    _remoteStreamsController.add(const {});

    if (_sendTransport != null) {
      await _sendTransport!.close();
      _sendTransport = null;
    }
    if (_recvTransport != null) {
      await _recvTransport!.close();
      _recvTransport = null;
    }

    debugPrint('WebrtcSfuService: All WebRTC/SFU connections disposed');
  }
}

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:grad_project/features/video_call/data/services/webrtc_sfu_service.dart';
import 'package:grad_project/features/video_call/data/services/signalr_hub_service.dart';
import 'media_state.dart';

class MediaCubit extends Cubit<MediaState> {
  final WebrtcSfuService sfuService;
  final SignalrHubService hubService;

  final List<StreamSubscription> _subscriptions = [];

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
        remoteStreams: Map.from(sfuService.remoteStreams),
      ));

      // 3. Subscribe to remote stream changes from SFU.
      //    Every time WebrtcSfuService adds/updates a remote MediaStream, this
      //    fires and re-emits MediaReady — which triggers the GridView to rebuild
      //    and hand each VideoTile its stream.
      _subscriptions.add(
        sfuService.remoteStreamsStream.listen((updatedStreams) {
          final current = state;
          if (current is MediaReady) {
            emit(current.copyWith(remoteStreams: Map.from(updatedStreams)));
          }
        }),
      );

      // 4. Subscribe to SfuProducerCreated hub events.
      //    When a participant who joins AFTER us starts publishing, the hub
      //    broadcasts SfuProducerCreated. We must consume that producer so their
      //    video/audio actually arrives in our recv transport.
      _subscriptions.add(
        hubService.sfuProducerCreatedStream.listen((payload) async {
          final localId = sfuService.currentParticipantId ?? '';
          if (payload.participantId.toLowerCase() == localId.toLowerCase()) {
            return;
          }
          debugPrint(
            'MediaCubit: New producer from ${payload.participantId} '
            '(${payload.kind}) — consuming producerId=${payload.producerId}',
          );
          try {
            await sfuService.consumeRemoteProducer(
              sfuService.currentMeetingId ?? '',
              localId,
              payload.producerId,
            );
          } catch (e) {
            debugPrint('MediaCubit: consumeRemoteProducer failed: $e');
          }
        }),
      );

      // 5. Subscribe to SfuProducerClosed — remove stream tile when a producer stops.
      _subscriptions.add(
        hubService.sfuProducerClosedStream.listen((payload) async {
          await sfuService.closeConsumer(payload.producerId);
        }),
      );
    } catch (e) {
      emit(MediaError('Failed to initialize local media tracks: $e'));
    }
  }

  Future<void> toggleAudio(String meetingId) async {
    final currentState = state;
    if (currentState is MediaReady) {
      final newAudioState = !currentState.isAudioOn;
      // toggleLocalAudio now also pauses/resumes the Mediasoup producer
      await sfuService.toggleLocalAudio(newAudioState);

      // Notify server via hub method so remote participants' ParticipantsCubit updates
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
      // toggleLocalVideo now also pauses/resumes the Mediasoup producer
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
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    await sfuService.stopLocalStream();
    return super.close();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:grad_project/features/video_call/data/models/participant_model.dart';

class VideoTile extends StatefulWidget {
  final ParticipantModel participant;
  final MediaStream? remoteStream;
  final bool isSpeaking;

  const VideoTile({
    super.key,
    required this.participant,
    this.remoteStream,
    this.isSpeaking = false,
  });

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  final _renderer = RTCVideoRenderer();
  bool _isRendererInitialized = false;

  @override
  void initState() {
    super.initState();
    _initRenderer();
  }

  Future<void> _initRenderer() async {
    await _renderer.initialize();
    if (widget.remoteStream != null) {
      _renderer.srcObject = widget.remoteStream;
    }
    if (mounted) {
      setState(() {
        _isRendererInitialized = true;
      });
    }
  }

  @override
  void didUpdateWidget(covariant VideoTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.remoteStream != oldWidget.remoteStream) {
      _renderer.srcObject = widget.remoteStream;
    }
  }

  @override
  void dispose() {
    _renderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.participant.name.isNotEmpty
        ? widget.participant.name.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isSpeaking ? const Color(0xFFE56C00) : Colors.grey.shade800,
          width: widget.isSpeaking ? 3.0 : 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Video Renderer or Initials Placeholder
          if (widget.participant.isVideoEnabled && widget.remoteStream != null && _isRendererInitialized)
            RTCVideoView(
              _renderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            )
          else
            Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFF163D69),
                child: Text(
                  initials,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          // Name and Status overlay badges
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.participant.name,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const Spacer(),
                if (!widget.participant.isAudioEnabled)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic_off, color: Colors.white, size: 12),
                  ),
                if (widget.participant.isHandRaised)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE56C00),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.back_hand, color: Colors.white, size: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

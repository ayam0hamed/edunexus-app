import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:grad_project/features/video_call/data/models/participant_model.dart';

class VideoTile extends StatefulWidget {
  final ParticipantModel participant;
  final MediaStream? stream;
  final bool isLocal;
  final bool isSpeaking;
  final String role;

  const VideoTile({
    super.key,
    required this.participant,
    this.stream,
    this.isLocal = false,
    this.isSpeaking = false,
    this.role = 'Participant',
  });

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  final _renderer = RTCVideoRenderer();
  bool _isRendererInitialized = false;

  // Holds a stream that arrived while initialize() was still in-flight.
  MediaStream? _pendingStream;

  @override
  void initState() {
    super.initState();
    _initRenderer();
  }

  Future<void> _initRenderer() async {
    await _renderer.initialize();
    if (!mounted) return;

    final streamToApply = _pendingStream ?? widget.stream;
    _pendingStream = null;
    _renderer.srcObject = streamToApply;

    setState(() {
      _isRendererInitialized = true;
    });
  }

  @override
  void didUpdateWidget(covariant VideoTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stream != oldWidget.stream) {
      if (_isRendererInitialized) {
        _renderer.srcObject = widget.stream;
      } else {
        _pendingStream = widget.stream;
      }
    }
  }

  @override
  void dispose() {
    _renderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          if (widget.participant.isVideoEnabled && widget.stream != null && _isRendererInitialized)
            RTCVideoView(
              _renderer,
              mirror: widget.isLocal,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            )
          else
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF163D69),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.role,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                    widget.isLocal ? 'You' : widget.participant.name,
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

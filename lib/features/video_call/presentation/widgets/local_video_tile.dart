import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class LocalVideoTile extends StatefulWidget {
  final MediaStream? localStream;
  final bool isVideoEnabled;
  final bool isAudioEnabled;
  final String name;

  const LocalVideoTile({
    super.key,
    this.localStream,
    required this.isVideoEnabled,
    required this.isAudioEnabled,
    required this.name,
  });

  @override
  State<LocalVideoTile> createState() => _LocalVideoTileState();
}

class _LocalVideoTileState extends State<LocalVideoTile> {
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

    // Apply either the pending (latest) stream or the current widget stream.
    final streamToApply = _pendingStream ?? widget.localStream;
    _pendingStream = null;
    _renderer.srcObject = streamToApply;

    setState(() {
      _isRendererInitialized = true;
    });
  }

  @override
  void didUpdateWidget(covariant LocalVideoTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.localStream != oldWidget.localStream) {
      if (_isRendererInitialized) {
        // Renderer is ready — apply immediately.
        _renderer.srcObject = widget.localStream;
      } else {
        // Renderer is still initializing — stash it so _initRenderer picks it up.
        _pendingStream = widget.localStream;
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
    final initials = widget.name.isNotEmpty
        ? widget.name.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'Me';

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Video Renderer or Initials Placeholder
          if (widget.isVideoEnabled && widget.localStream != null && _isRendererInitialized)
            RTCVideoView(
              _renderer,
              mirror: true,
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

          // Name and Mute indicator overlay
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
                  child: const Text(
                    'You',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const Spacer(),
                if (!widget.isAudioEnabled)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic_off, color: Colors.white, size: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

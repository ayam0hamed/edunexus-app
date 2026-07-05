import 'package:flutter/material.dart';

class ControlBar extends StatelessWidget {
  final bool isAudioOn;
  final bool isVideoOn;
  final bool isScreenSharing;
  final bool isHandRaised;
  final int unreadChatCount;
  
  final VoidCallback onToggleAudio;
  final VoidCallback onToggleVideo;
  final VoidCallback onSwitchCamera;
  final VoidCallback onToggleScreenShare;
  final VoidCallback onToggleHandRaise;
  final VoidCallback onToggleChat;
  final VoidCallback onShowParticipants;
  final VoidCallback onLeaveMeeting;

  const ControlBar({
    super.key,
    required this.isAudioOn,
    required this.isVideoOn,
    required this.isScreenSharing,
    required this.isHandRaised,
    required this.unreadChatCount,
    required this.onToggleAudio,
    required this.onToggleVideo,
    required this.onSwitchCamera,
    required this.onToggleScreenShare,
    required this.onToggleHandRaise,
    required this.onToggleChat,
    required this.onShowParticipants,
    required this.onLeaveMeeting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.grey.shade900,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Audio Toggle
          _controlButton(
            icon: isAudioOn ? Icons.mic : Icons.mic_off,
            color: isAudioOn ? Colors.grey.shade800 : Colors.redAccent,
            onPressed: onToggleAudio,
            tooltip: 'Toggle Mic',
          ),

          // Video Toggle
          _controlButton(
            icon: isVideoOn ? Icons.videocam : Icons.videocam_off,
            color: isVideoOn ? Colors.grey.shade800 : Colors.redAccent,
            onPressed: onToggleVideo,
            tooltip: 'Toggle Camera',
          ),

          // Switch Camera
          if (isVideoOn)
            _controlButton(
              icon: Icons.flip_camera_ios,
              color: Colors.grey.shade800,
              onPressed: onSwitchCamera,
              tooltip: 'Switch Camera',
            ),

          // Screen Share
          _controlButton(
            icon: isScreenSharing ? Icons.screen_share : Icons.stop_screen_share,
            color: isScreenSharing ? const Color(0xFF163D69) : Colors.grey.shade800,
            onPressed: onToggleScreenShare,
            tooltip: 'Screen Share',
          ),

          // Hand Raise
          _controlButton(
            icon: isHandRaised ? Icons.back_hand : Icons.back_hand_outlined,
            color: isHandRaised ? const Color(0xFFE56C00) : Colors.grey.shade800,
            onPressed: onToggleHandRaise,
            tooltip: 'Raise Hand',
          ),

          // Chat Overlay with Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              _controlButton(
                icon: Icons.chat_bubble_outline,
                color: Colors.grey.shade800,
                onPressed: onToggleChat,
                tooltip: 'Chat',
              ),
              if (unreadChatCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      unreadChatCount > 9 ? '9+' : '$unreadChatCount',
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),

          // Participant List
          _controlButton(
            icon: Icons.people_outline,
            color: Colors.grey.shade800,
            onPressed: onShowParticipants,
            tooltip: 'Participants',
          ),

          // Hang up (Leave)
          _controlButton(
            icon: Icons.call_end,
            color: Colors.redAccent,
            onPressed: onLeaveMeeting,
            tooltip: 'Leave Call',
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: color,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}

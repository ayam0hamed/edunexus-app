import 'package:flutter/material.dart';

class InstructorControls extends StatelessWidget {
  final bool isMeetingLocked;
  final VoidCallback onMuteAll;
  final ValueChanged<bool> onToggleLock;
  final VoidCallback onEndMeeting;

  const InstructorControls({
    super.key,
    required this.isMeetingLocked,
    required this.onMuteAll,
    required this.onToggleLock,
    required this.onEndMeeting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey.shade900.withOpacity(0.95),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute All Button
          ElevatedButton.icon(
            onPressed: onMuteAll,
            icon: const Icon(Icons.mic_off, size: 16, color: Colors.white),
            label: const Text('Mute All', style: TextStyle(color: Colors.white, fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

          // Lock Meeting Toggle
          OutlinedButton.icon(
            onPressed: () => onToggleLock(!isMeetingLocked),
            icon: Icon(isMeetingLocked ? Icons.lock : Icons.lock_open, size: 16, color: Colors.white),
            label: Text(
              isMeetingLocked ? 'Unlock Meeting' : 'Lock Meeting',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

          // End Meeting Button
          ElevatedButton.icon(
            onPressed: onEndMeeting,
            icon: const Icon(Icons.cancel, size: 16, color: Colors.white),
            label: const Text('End Meeting', style: TextStyle(color: Colors.white, fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

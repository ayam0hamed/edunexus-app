import 'package:flutter/material.dart';
import 'package:grad_project/features/video_call/data/models/participant_model.dart';

class ParticipantListSheet extends StatelessWidget {
  final List<ParticipantModel> participants;
  final bool isInstructor;
  final String currentParticipantId;
  final Function(String) onKickParticipant;

  const ParticipantListSheet({
    super.key,
    required this.participants,
    required this.isInstructor,
    required this.currentParticipantId,
    required this.onKickParticipant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Participants (${participants.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          if (participants.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No participants in this call.', style: TextStyle(color: Colors.black54))),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final p = participants[index];
                  final isMe = p.id == currentParticipantId;
                  
                  return _AnimatedParticipantItem(
                    p: p,
                    isMe: isMe,
                    isInstructor: isInstructor,
                    index: index,
                    onKick: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Kick Participant'),
                          content: Text('Are you sure you want to kick ${p.name}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                onKickParticipant(p.id);
                                Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                              child: const Text('Kick', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _AnimatedParticipantItem extends StatelessWidget {
  final ParticipantModel p;
  final bool isMe;
  final bool isInstructor;
  final int index;
  final VoidCallback onKick;

  const _AnimatedParticipantItem({
    required this.p,
    required this.isMe,
    required this.isInstructor,
    required this.index,
    required this.onKick,
  });

  @override
  Widget build(BuildContext context) {
    // If you are the instructor, you see 'Instructor' for yourself and 'Student' for others.
    // If you are a student, you see 'Student' for yourself, and 'Participant' for others.
    final String role = isMe 
        ? (isInstructor ? 'Instructor' : 'Student') 
        : (isInstructor ? 'Student' : 'Participant');

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 500)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Role Badge instead of Avatar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDAF3FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                role,
                style: const TextStyle(
                  color: Color(0xFF163D69),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name
            Expanded(
              child: Text(
                isMe ? '${p.name} (You)' : p.name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Hand Raised
            if (p.isHandRaised)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.back_hand, color: Color(0xFFE56C00), size: 18),
              ),
            // Mic icon
            Icon(
              p.isAudioEnabled ? Icons.mic : Icons.mic_off,
              color: p.isAudioEnabled ? Colors.green : Colors.redAccent,
              size: 20,
            ),
            const SizedBox(width: 8),
            // Video icon
            Icon(
              p.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
              color: p.isVideoEnabled ? Colors.green : Colors.redAccent,
              size: 20,
            ),
            // Kick button
            if (isInstructor && !isMe) ...[
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 24,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.person_remove, color: Colors.redAccent, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onKick,
                tooltip: 'Kick Participant',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

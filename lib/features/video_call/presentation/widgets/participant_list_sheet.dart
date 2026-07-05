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
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final p = participants[index];
                  final isMe = p.id == currentParticipantId;
                  
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFDAF3FF),
                      child: Text(
                        p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Color(0xFF163D69), fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      isMe ? '${p.name} (You)' : p.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (p.isHandRaised)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.back_hand, color: Color(0xFFE56C00), size: 18),
                          ),
                        Icon(
                          p.isAudioEnabled ? Icons.mic : Icons.mic_off,
                          color: p.isAudioEnabled ? Colors.green : Colors.redAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          p.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                          color: p.isVideoEnabled ? Colors.green : Colors.redAccent,
                          size: 18,
                        ),
                        if (isInstructor && !isMe) ...[
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.person_remove, color: Colors.redAccent),
                            onPressed: () {
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
                            tooltip: 'Kick Participant',
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:equatable/equatable.dart';

class ChatMessageModel extends Equatable {
  final String id;
  final String meetingId;
  final String senderId;
  final String senderDisplayName;
  final String content;
  final String sentAt;

  const ChatMessageModel({
    required this.id,
    required this.meetingId,
    required this.senderId,
    required this.senderDisplayName,
    required this.content,
    required this.sentAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      meetingId: json['meetingId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderDisplayName: json['senderDisplayName']?.toString() ?? json['userName']?.toString() ?? 'Unknown',
      content: json['content']?.toString() ?? '',
      sentAt: json['sentAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'meetingId': meetingId,
        'senderId': senderId,
        'senderDisplayName': senderDisplayName,
        'content': content,
        'sentAt': sentAt,
      };

  @override
  List<Object?> get props => [id, meetingId, senderId, senderDisplayName, content, sentAt];
}

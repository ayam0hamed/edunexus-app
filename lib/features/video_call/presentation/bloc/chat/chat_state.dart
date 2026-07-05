import 'package:equatable/equatable.dart';
import 'package:grad_project/features/video_call/data/models/chat_message_model.dart';

class ChatState extends Equatable {
  final List<ChatMessageModel> messages;
  final int unreadCount;
  final bool isOpen;

  const ChatState({
    required this.messages,
    this.unreadCount = 0,
    this.isOpen = false,
  });

  ChatState copyWith({
    List<ChatMessageModel>? messages,
    int? unreadCount,
    bool? isOpen,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
      isOpen: isOpen ?? this.isOpen,
    );
  }

  @override
  List<Object?> get props => [messages, unreadCount, isOpen];
}

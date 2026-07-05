import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:grad_project/features/video_call/data/services/signalr_hub_service.dart';
import 'package:grad_project/features/video_call/data/services/video_call_api_service.dart';
import 'package:grad_project/features/video_call/data/models/chat_message_model.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final SignalrHubService hubService;
  final VideoCallApiService apiService;

  StreamSubscription? _chatSubscription;

  ChatCubit({
    required this.hubService,
    required this.apiService,
  }) : super(const ChatState(messages: [])) {
    _subscribeToChatEvents();
  }

  Future<void> loadHistory(String meetingId) async {
    try {
      final messages = await apiService.getChatHistory(meetingId);
      emit(state.copyWith(messages: messages));
    } catch (e) {
      debugPrint('ChatCubit: Failed to load chat history: $e');
    }
  }

  void _subscribeToChatEvents() {
    _chatSubscription = hubService.receiveChatMessageStream.listen((message) {
      final list = List<ChatMessageModel>.from(state.messages)..add(message);
      
      // Update unread count if the chat panel is currently closed
      final newUnreadCount = state.isOpen ? 0 : state.unreadCount + 1;
      
      emit(state.copyWith(
        messages: list,
        unreadCount: newUnreadCount,
      ));
    });
  }

  Future<void> sendMessage(String meetingId, String content) async {
    if (content.trim().isEmpty) return;
    try {
      await hubService.sendChatMessage(meetingId, content);
    } catch (e) {
      debugPrint('ChatCubit: Failed to send message: $e');
    }
  }

  void toggleChat() {
    final newOpenState = !state.isOpen;
    emit(state.copyWith(
      isOpen: newOpenState,
      unreadCount: newOpenState ? 0 : state.unreadCount,
    ));
  }

  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    return super.close();
  }
}

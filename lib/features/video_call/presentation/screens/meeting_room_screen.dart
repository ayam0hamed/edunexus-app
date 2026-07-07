import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:grad_project/features/video_call/data/services/signalr_hub_service.dart';
import 'package:grad_project/features/video_call/presentation/bloc/chat/chat_cubit.dart';
import 'package:grad_project/features/video_call/presentation/bloc/chat/chat_state.dart';
import 'package:grad_project/features/video_call/presentation/bloc/media/media_cubit.dart';
import 'package:grad_project/features/video_call/presentation/bloc/media/media_state.dart';
import 'package:grad_project/features/video_call/presentation/bloc/participants/participants_cubit.dart';
import 'package:grad_project/features/video_call/presentation/bloc/participants/participants_state.dart';
import 'package:grad_project/features/video_call/presentation/bloc/quiz/quiz_cubit.dart';
import 'package:grad_project/features/video_call/presentation/bloc/quiz/quiz_state.dart';
import 'package:grad_project/features/video_call/presentation/bloc/reactions/reactions_cubit.dart';
import 'package:grad_project/features/video_call/presentation/bloc/reactions/reactions_state.dart';
import 'package:grad_project/features/video_call/presentation/bloc/video_call/video_call_cubit.dart';
import 'package:grad_project/features/video_call/presentation/bloc/video_call/video_call_state.dart';
import 'package:grad_project/features/video_call/presentation/widgets/chat_sheet.dart';
import 'package:grad_project/features/video_call/presentation/widgets/control_bar.dart';
import 'package:grad_project/features/video_call/presentation/widgets/emoji_reaction_overlay.dart';
import 'package:grad_project/features/video_call/presentation/widgets/instructor_controls.dart';
import 'package:grad_project/features/video_call/presentation/widgets/meeting_app_bar.dart';
import 'package:grad_project/features/video_call/presentation/widgets/participant_list_sheet.dart';
import 'package:grad_project/features/video_call/presentation/widgets/quiz_sheet.dart';
import 'package:grad_project/features/video_call/presentation/widgets/video_tile.dart';

class MeetingRoomScreen extends StatefulWidget {
  final String meetingId;

  const MeetingRoomScreen({super.key, required this.meetingId});

  @override
  State<MeetingRoomScreen> createState() => _MeetingRoomScreenState();
}

class _MeetingRoomScreenState extends State<MeetingRoomScreen> {
  final _hubService = GetIt.I<SignalrHubService>();
  final List<StreamSubscription> _subscriptions = [];

  bool _isMeetingLocked = false;
  bool _isChatEnabled = true;

  @override
  void initState() {
    super.initState();
    _subscribeToHubStreams();
  }

  void _subscribeToHubStreams() {
    _subscriptions.addAll([
      _hubService.youWereKickedStream.listen((kickedBy) {
        _showEndDialog('You Were Kicked', 'You were kicked from this meeting by an instructor.');
      }),
      _hubService.meetingEndedStream.listen((endedBy) {
        _showEndDialog('Meeting Ended', 'This meeting session has been ended by the host.');
      }),
      _hubService.meetingLockToggledStream.listen((payload) {
        setState(() {
          _isMeetingLocked = payload.locked;
        });
      }),
      _hubService.chatToggledStream.listen((payload) {
        setState(() {
          _isChatEnabled = payload.enabled;
        });
      }),
    ]);
  }

  void _showEndDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<VideoCallCubit>().leaveMeeting();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF163D69)),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  void _handleLeaveOrEnd(BuildContext context, bool isInstructor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Meeting'),
        content: Text(isInstructor ? 'Do you want to leave the meeting or end it for all participants?' : 'Are you sure you want to leave the meeting?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<VideoCallCubit>().leaveMeeting();
              Navigator.pop(context);
            },
            child: const Text('Leave'),
          ),
          if (isInstructor)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<VideoCallCubit>().endMeeting();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('End Meeting', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoCallCubit, VideoCallState>(
      builder: (context, callState) {
        if (callState is! VideoCallJoined) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Color(0xFF163D69))),
          );
        }

        final isInstructor = callState.isInstructor;

        return MultiBlocProvider(
          providers: [
            BlocProvider<MediaCubit>(create: (_) => GetIt.I<MediaCubit>()..initMedia()),
            BlocProvider<ParticipantsCubit>(create: (_) => GetIt.I<ParticipantsCubit>()..loadParticipants(
              widget.meetingId,
              localId: callState.participantId,
              localName: callState.userName,
            )),
            BlocProvider<ChatCubit>(create: (_) => GetIt.I<ChatCubit>()..loadHistory(widget.meetingId)),
            BlocProvider<QuizCubit>(create: (_) => GetIt.I<QuizCubit>()),
            BlocProvider<ReactionsCubit>(create: (_) => GetIt.I<ReactionsCubit>()),
          ],
          child: Builder(
            builder: (context) {
              return Scaffold(
                backgroundColor: Colors.black,
                appBar: MeetingAppBar(
                  title: 'Class Meeting ID: ${widget.meetingId.substring(0, 8)}',
                  isLocked: _isMeetingLocked,
                  onBack: () => _handleLeaveOrEnd(context, isInstructor),
                ),
                body: WillPopScope(
                  onWillPop: () async {
                    _handleLeaveOrEnd(context, isInstructor);
                    return false;
                  },
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          // Video Grid
                          Expanded(
                            child: BlocBuilder<MediaCubit, MediaState>(
                              builder: (context, mediaState) {
                                return BlocBuilder<ParticipantsCubit, ParticipantsState>(
                                  builder: (context, pState) {
                                    // ── Read remote streams from state ────────────
                                    final remoteStreams = mediaState is MediaReady
                                        ? mediaState.remoteStreams
                                        : const <String, MediaStream>{};

                                    // ── Build all tiles ─────────────────────────
                                    final allTiles = pState.participants.map((p) {
                                      final isMe = p.id.toLowerCase() == callState.participantId.toLowerCase();
                                      final stream = isMe
                                          ? (mediaState is MediaReady ? mediaState.localStream : null)
                                          : remoteStreams[p.id.toLowerCase()];
                                      return VideoTile(
                                        key: ValueKey(p.id.toLowerCase()),
                                        participant: p,
                                        stream: stream,
                                        isLocal: isMe,
                                      );
                                    }).toList();

                                    // ── Responsive layout ────────────────────────
                                    return _buildResponsiveGrid(allTiles, allTiles.length);
                                  },
                                );
                              },
                            ),
                          ),

                      // Instructor controls
                      if (isInstructor)
                        InstructorControls(
                          isMeetingLocked: _isMeetingLocked,
                          onMuteAll: () {
                            context.read<ParticipantsCubit>().muteAll(widget.meetingId);
                          },
                          onToggleLock: (lock) async {
                            await _hubService.lockMeeting(widget.meetingId, lock);
                            setState(() {
                              _isMeetingLocked = lock;
                            });
                          },
                          onEndMeeting: () => _handleLeaveOrEnd(context, true),
                        ),

                      // Control Bar
                      BlocBuilder<MediaCubit, MediaState>(
                        builder: (context, mediaState) {
                          final isAudioOn = mediaState is MediaReady ? mediaState.isAudioOn : false;
                          final isVideoOn = mediaState is MediaReady ? mediaState.isVideoOn : false;
                          final isScreenSharing = mediaState is MediaReady ? mediaState.isScreenSharing : false;

                          return BlocBuilder<ReactionsCubit, ReactionsState>(
                            builder: (context, rState) {
                              final isHandRaised = rState.raisedHands.contains(callState.participantId.toLowerCase());

                              return BlocBuilder<ChatCubit, ChatState>(
                                builder: (context, chatState) {
                                  return ControlBar(
                                    isAudioOn: isAudioOn,
                                    isVideoOn: isVideoOn,
                                    isScreenSharing: isScreenSharing,
                                    isHandRaised: isHandRaised,
                                    unreadChatCount: chatState.unreadCount,
                                    onToggleAudio: () {
                                      context.read<MediaCubit>().toggleAudio(widget.meetingId);
                                      context.read<ParticipantsCubit>().updateParticipantAudio(
                                        callState.participantId,
                                        !isAudioOn,
                                      );
                                    },
                                    onToggleVideo: () {
                                      context.read<MediaCubit>().toggleVideo(widget.meetingId);
                                      context.read<ParticipantsCubit>().updateParticipantVideo(
                                        callState.participantId,
                                        !isVideoOn,
                                      );
                                    },
                                    onSwitchCamera: () => context.read<MediaCubit>().switchCamera(),
                                    onToggleScreenShare: () {
                                      if (isScreenSharing) {
                                        context.read<MediaCubit>().stopScreenShare(widget.meetingId);
                                      } else {
                                        context.read<MediaCubit>().startScreenShare(widget.meetingId);
                                      }
                                    },
                                    onToggleHandRaise: () {
                                      context.read<ReactionsCubit>().toggleHandRaise(
                                            widget.meetingId,
                                            callState.participantId,
                                            !isHandRaised,
                                          );
                                      context.read<ParticipantsCubit>().updateParticipantHand(
                                            callState.participantId,
                                            !isHandRaised,
                                          );
                                    },
                                    onToggleChat: () {
                                      if (!_isChatEnabled && !isInstructor) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Chat has been disabled by the instructor.')),
                                        );
                                        return;
                                      }
                                      _showChatSheet(context, callState.meetingId);
                                    },
                                    onShowParticipants: () => _showParticipantsSheet(context, callState.meetingId, callState.participantId),
                                    onLeaveMeeting: () => _handleLeaveOrEnd(context, isInstructor),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),

                  // Live animated emojis overlay
                  BlocBuilder<ReactionsCubit, ReactionsState>(
                    builder: (context, rState) {
                      return EmojiReactionOverlay(recentReojis: rState.recentReojis);
                    },
                  ),

                  // Floating Reactions picker & Quiz triggers
                  Positioned(
                    bottom: isInstructor ? 128 : 80,
                    right: 16,
                    child: Column(
                      children: [
                        // Reactions Trigger Button
                        FloatingActionButton(
                          mini: true,
                          heroTag: 'reactionsBtn',
                          backgroundColor: const Color(0xFFE56C00),
                          child: const Icon(Icons.mood, color: Colors.white),
                          onPressed: () => _showReactionsPicker(context, callState.meetingId, callState.userName),
                        ),
                        const SizedBox(height: 8),
                        // Quiz Sheet Trigger
                        FloatingActionButton(
                          mini: true,
                          heroTag: 'quizBtn',
                          backgroundColor: const Color(0xFF163D69),
                          child: const Icon(Icons.quiz, color: Colors.white),
                          onPressed: () => _showQuizSheet(context, callState.meetingId, isInstructor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showChatSheet(BuildContext context, String meetingId) {
    final chatCubit = context.read<ChatCubit>();
    chatCubit.toggleChat(); // Mark read

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider<ChatCubit>.value(
        value: chatCubit,
        child: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: ChatSheet(
                messages: state.messages,
                onSendMessage: (text) => chatCubit.sendMessage(meetingId, text),
              ),
            );
          },
        ),
      ),
    ).whenComplete(() => chatCubit.toggleChat()); // Mark closed
  }

  void _showParticipantsSheet(BuildContext context, String meetingId, String currentParticipantId) {
    final pCubit = context.read<ParticipantsCubit>();
    final isInstructor = context.read<VideoCallCubit>().state is VideoCallJoined &&
        (context.read<VideoCallCubit>().state as VideoCallJoined).isInstructor;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider<ParticipantsCubit>.value(
        value: pCubit,
        child: BlocBuilder<ParticipantsCubit, ParticipantsState>(
          builder: (context, state) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: ParticipantListSheet(
                participants: state.participants,
                isInstructor: isInstructor,
                currentParticipantId: currentParticipantId,
                onKickParticipant: (id) => pCubit.kickParticipant(meetingId, id),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showQuizSheet(BuildContext context, String meetingId, bool isInstructor) {
    final quizCubit = context.read<QuizCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider<QuizCubit>.value(
        value: quizCubit,
        child: BlocBuilder<QuizCubit, QuizState>(
          builder: (context, state) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: QuizSheet(
                state: state,
                isInstructor: isInstructor,
                meetingId: meetingId,
                onCreateQuiz: (mId, questions) => quizCubit.createAndStartQuiz(mId, questions),
                onStopQuiz: (sId) => quizCubit.stopQuiz(sId),
                onSubmitAnswer: (qId, option) => quizCubit.submitAnswer(qId, option),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showReactionsPicker(BuildContext context, String meetingId, String userName) {
    final reactionsCubit = context.read<ReactionsCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Send a Reaction', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['👍', '👏', '💖', '😂', '🎉', '😮', '❓', '🔥'].map((emoji) {
                return InkWell(
                  onTap: () {
                    reactionsCubit.sendReaction(meetingId, emoji, userName);
                    Navigator.pop(ctx);
                  },
                  child: Text(emoji, style: const TextStyle(fontSize: 32)),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Responsive video grid:
  /// • 1 tile  → full-screen
  /// • 2 tiles → two equal rows
  /// • 3-4     → 2-column grid
  /// • 5+      → 3-column adaptive grid
  Widget _buildResponsiveGrid(List<Widget> tiles, int count) {
    if (count == 0) return const SizedBox.shrink();

    if (count == 1) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: tiles[0],
        ),
      );
    }

    if (count == 2) {
      return Column(
        children: tiles
            .map((t) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: t,
                    ),
                  ),
                ))
            .toList(),
      );
    }

    // 3+ participants — grid layout
    final crossAxisCount = count <= 4 ? 2 : 3;
    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      childAspectRatio: count <= 4 ? 1.0 : 0.85,
      shrinkWrap: false,
      physics: const NeverScrollableScrollPhysics(),
      children: tiles,
    );
  }
}

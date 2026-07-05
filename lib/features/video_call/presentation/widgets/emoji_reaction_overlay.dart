import 'package:flutter/material.dart';
import 'package:grad_project/features/video_call/presentation/bloc/reactions/reactions_state.dart';

class EmojiReactionOverlay extends StatelessWidget {
  final List<ReactionEvent> recentReojis;

  const EmojiReactionOverlay({
    super.key,
    required this.recentReojis,
  });

  @override
  Widget build(BuildContext context) {
    if (recentReojis.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: Stack(
        children: recentReojis.map((re) {
          // Position emoji randomly horizontally and animate vertically
          final double leftPos = 40.0 + (re.id.hashCode % (MediaQuery.of(context).size.width - 100));

          return AnimatedReaction(
            key: ValueKey(re.id),
            left: leftPos,
            emoji: re.emoji,
            fullName: re.fullName,
          );
        }).toList(),
      ),
    );
  }
}

class AnimatedReaction extends StatefulWidget {
  final double left;
  final String emoji;
  final String fullName;

  const AnimatedReaction({
    super.key,
    required this.left,
    required this.emoji,
    required this.fullName,
  });

  @override
  State<AnimatedReaction> createState() => _AnimatedReactionState();
}

class _AnimatedReactionState extends State<AnimatedReaction> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _yAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _yAnim = Tween<double>(begin: 0.0, end: 350.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnim = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final currentY = screenHeight - 120 - _yAnim.value;

        return Positioned(
          left: widget.left,
          top: currentY,
          child: Opacity(
            opacity: _opacityAnim.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.fullName.split(' ').first,
                    style: const TextStyle(color: Colors.white, fontSize: 8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

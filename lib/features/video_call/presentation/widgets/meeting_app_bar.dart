import 'dart:async';
import 'package:flutter/material.dart';

class MeetingAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool isLocked;
  final VoidCallback onBack;

  const MeetingAppBar({
    super.key,
    required this.title,
    required this.isLocked,
    required this.onBack,
  });

  @override
  State<MeetingAppBar> createState() => _MeetingAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MeetingAppBarState extends State<MeetingAppBar> {
  late final Stopwatch _stopwatch;
  late final Timer _timer;
  String _timeElapsedStr = '00:00';

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          final minutes = _stopwatch.elapsed.inMinutes.toString().padLeft(2, '0');
          final seconds = (_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');
          _timeElapsedStr = '$minutes:$seconds';
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey.shade900,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: widget.onBack,
      ),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _timeElapsedStr,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                ),
              ],
            ),
          ),
          if (widget.isLocked)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.lock, color: Colors.redAccent, size: 16),
            ),
          // Recording status placeholder
          Container(
            margin: const EdgeInsets.only(left: 12),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.redAccent, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                const Text('REC', style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

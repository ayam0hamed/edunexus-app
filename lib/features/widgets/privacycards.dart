import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:grad_project/features/widgets/switch.dart';

class Privacycards extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  //final bool isEnabled;
  const Privacycards({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    //required this.isEnabled,
  });

  @override
  State<Privacycards> createState() => _PrivacycardsState();
}

class _PrivacycardsState extends State<Privacycards> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      width: 320,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF163D69)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(widget.icon, color: const Color(0xFF163D69), size: 16),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: "inter",
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                      fontFamily: "inter",
                    ),
                  ),
                ],
              ),
            ],
          ),

          // FlutterSwitch(
          //   value: _isEnabled,
          //   onToggle: (value) {
          //     setState(() {
          //       _isEnabled = value;
          //     });
          //   },
          //   activeColor: const Color(0xFF89B6FC),
          //   inactiveColor: const Color(0xFFECECEC),

          //   height: 10,
          //   width: 20,
          //   toggleSize: 12,
          //   borderRadius: 20,
          //   padding: 2,
          // ),
        ],
      ),
    );
  }
}

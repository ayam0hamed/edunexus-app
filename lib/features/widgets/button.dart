import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final VoidCallback onPressed;
  final String text;
  final IconData? icon; // optional
  final double iconsize = 24.0;
  final double? border;
  final TextStyle? textStyle;

  const GradientButton({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.onPressed,
    required this.text,
    this.icon,
    this.border,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF163D69), Color(0xFFEC5600)],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: border != null
            ? Border.all(color: Colors.white, width: border!)
            : null,
      ),

      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: iconsize),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              textAlign: TextAlign.center,
              style:
                  textStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

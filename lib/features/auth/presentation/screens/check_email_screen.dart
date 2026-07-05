import 'package:flutter/material.dart';
import 'package:grad_project/core/routing/app_routes.dart';
import 'package:grad_project/features/widgets/button.dart';

class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: const Color.fromARGB(255, 94, 92, 95),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF003366),
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const Text(
              'Check Your Email',
              style: TextStyle(
                color: Color(0xFF003366),
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: "poppins",
              ),
            ),
            const Spacer(),
            Image.asset(
              'assets/images/platform.png',
              height: 46,
              width: 60,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.school, color: Color(0xFF003366)),
            ),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: "poppins",
                ),
                children: [
                  TextSpan(
                    text: 'Edu',
                    style: TextStyle(color: Color(0xFF163D69)),
                  ),
                  TextSpan(
                    text: 'Nexus',
                    style: TextStyle(color: Color(0xFFE56C00)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Image.asset(
              'assets/images/verify.png',
              height: 140,
              width: 140,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.mark_email_unread_outlined,
                color: Color(0xFF003366),
                size: 100,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Check your email',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 20,
                fontFamily: "poppins",
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "We've sent a password reset link to your email address.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontFamily: "poppins",
              ),
            ),
            const Spacer(),
            GradientButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              text: 'Back to Login',
              width: 347,
              height: 48,
              borderRadius: 10,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: "inter",
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

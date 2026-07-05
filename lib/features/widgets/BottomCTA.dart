import 'package:flutter/material.dart';
import 'package:grad_project/core/routing/app_routes.dart';
import 'package:grad_project/features/widgets/button.dart';

class BottomCTA extends StatelessWidget {
  const BottomCTA({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Bottom CTA
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEC5600), Color(0xFF0D253F)],
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Ready to Make Teaching Smarter?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'inter',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Join our smarter platform for effortless, engaging online meetings — wherever you are.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              fontFamily: 'inter',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'and make every session more interactive and productive',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              fontFamily: 'inter',
            ),
          ),
          const SizedBox(height: 20),
          GradientButton(
            width: 274,
            height: 48,
            borderRadius: 10,
            border: 1.0,
            icon: Icons.videocam,
            text: 'Start Teaching Free',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.login);
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'No credit card required -No hidden fees .Always free',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              fontFamily: 'poppins',
            ),
          ),
        ],
      ),
    );
  }
}

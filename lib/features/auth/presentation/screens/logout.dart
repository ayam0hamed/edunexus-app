import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/routing/app_routes.dart';
import 'package:grad_project/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grad_project/features/auth/presentation/bloc/auth_event.dart';
import 'package:grad_project/features/auth/presentation/bloc/auth_state.dart';
import 'package:grad_project/features/widgets/button.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

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
              'Logout',
              style: TextStyle(
                color: Color(0xFF003366),
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: "poppins",
              ),
            ),
            const Spacer(),
            Image.asset(
              'assets/images/platform.png', // Placeholder for EduNexus logo
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

      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          }
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logout.png', height: 140, width: 140),
                const SizedBox(height: 24),
                const Text(
                  'Are you sure you want to logout?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: "poppins",
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "You can sign in again anytime, but please make sure your recent activities and changes are saved before continuing.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[800],
                    fontFamily: "poppins",
                  ),
                ),
                const SizedBox(height: 30),
                GradientButton(
                  width: 342,
                  height: 48,
                  borderRadius: 10,
                  onPressed: () {
                    context.read<AuthBloc>().add(const LogoutRequested());
                  },
                  text: "Logout",
                  icon: Icons.arrow_forward,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: "inter",
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Color(0xFF003366)),
                    ),
                  ),
                  child: Container(
                    height: 30,
                    width: 342,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel_outlined, color: Color(0xFF003366)),
                        SizedBox(width: 8),
                        Text(
                          textAlign: TextAlign.center,
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF003366),
                            fontFamily: "inter",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grad_project/core/routing/app_routes.dart';
import 'package:grad_project/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grad_project/features/auth/presentation/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handleNavigation(context.read<AuthBloc>().state);
      }
    });
  }

  void _handleNavigation(AuthState state) {
    if (state is AuthAuthenticated) {
      if (state.role == 'Student') {
        Navigator.pushReplacementNamed(context, AppRoutes.studentscreen);
      } else if (state.role == 'Instructor') {
        Navigator.pushReplacementNamed(context, AppRoutes.instructorScreen);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        _handleNavigation(state);
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0D253F), // Dark Blue
                Color(0xFFE67E22), // Orange
              ],
            ),
          ),
          child: SizedBox(
            height: 507,
            width: 240,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 1),
                const Icon(
                  Icons.videocam_outlined,
                  size: 48,
                  color: Colors.white,
                ),
                Text(
                  'EDUNEXUS',
                  style: TextStyle(
                    color: Colors.white,
                    fontStyle: GoogleFonts.poppins().fontStyle,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(
                  color: Colors.white,
                  thickness: 4,
                  indent: 128,
                  endIndent: 128,
                  height: 30,
                ),
                //const SizedBox(height: 20),
                const Text(
                  'Enjoy Mask Free\nMeetings',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Image.asset('assets/images/splash.png', height: 272, width: 240),
                const Spacer(flex: 1),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.landingPage,
                    );
                  },
                  child: Container(
                    width: 240,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          Color(0xFF0D253F), // Dark Blue
                          Color(0xFFE67E22),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_forward, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Get Started',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontStyle: GoogleFonts.poppins().fontStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

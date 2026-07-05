import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grad_project/core/routing/app_routes.dart';
import 'package:grad_project/features/widgets/BottomCTA.dart';
import 'package:grad_project/features/widgets/button.dart';
import 'package:grad_project/features/onboarding/screens/overlay.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool showSidebar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        shadowColor: Color.fromARGB(255, 94, 92, 95),
        title: Row(
          children: [
            ImageIcon(AssetImage('assets/images/platform.png'), size: 65),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'Edu',
                    style: TextStyle(color: Color(0xFF163D69)),
                  ),
                  TextSpan(
                    text: 'Nuxus',
                    style: TextStyle(color: Color(0xFFE56C00)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              setState(() => showSidebar = true);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),

                /// Free banner
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7FFD8),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.card_giftcard, color: Colors.black, size: 18),
                      SizedBox(width: 8),
                      Text(
                        '100% Free Forever - No Hidden Costs',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        fontStyle: GoogleFonts.poppins().fontStyle,
                        height: 1.4,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Smarter Classroom\n',
                          style: TextStyle(color: Color(0xFF163D69)),
                        ),
                        TextSpan(
                          text: 'Where Learning Meets\nInnovation',
                          style: TextStyle(color: Color(0xFFE56C00)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Join Smarter Classroom and experience a new way of learning and teaching. '
                    'Connect with students and educators in real-time, share ideas effortlessly, '
                    'and make every class more interactive and engaging.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// CTA button
                GradientButton(
                  width: 353,
                  height: 48,
                  borderRadius: 10,
                  icon: Icons.videocam,
                  text: 'Start Teaching Free',
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                ),

                const SizedBox(height: 30),

                /// Features row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _FeatureItem(title: 'Free', subtitle: 'Always'),
                      _FeatureItem(title: 'Unlimited', subtitle: 'Students'),
                      _FeatureItem(title: 'AI-Powered', subtitle: 'Questions'),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// Preview card
                Container(
                  width: 343,
                  padding: const EdgeInsets.fromLTRB(0, 18, 0, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 306,
                        height: 237,
                        margin: const EdgeInsets.fromLTRB(24, 7, 24, 7),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),

                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: const [
                                CircleAvatar(
                                  radius: 6,
                                  backgroundColor: Colors.red,
                                ),
                                SizedBox(width: 6),
                                CircleAvatar(
                                  radius: 6,
                                  backgroundColor: Colors.yellow,
                                ),
                                SizedBox(width: 6),
                                CircleAvatar(
                                  radius: 6,
                                  backgroundColor: Colors.green,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Computer Vision – Live Now!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'assets/images/preview.png',
                                  height: 160,
                                  width: 258,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 208,
                        width: 306,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8ECF0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'AI Generated Quiz',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: const Color(0xFF163D69),
                                    fontFamily: 'roboto',
                                  ),
                                ),
                                Text(
                                  'Live Now !',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: const Color(0xFF163D69),
                                    fontFamily: 'roboto',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            /// Question
                            const Text(
                              'What is the main goal of Computer Vision?',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF163D69),
                                height: 1,
                                fontFamily: 'inter',
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// Option A
                            _QuizOption(
                              option: 'A',
                              text:
                                  'To enable computers to understand and interpret visual information.',
                            ),

                            const SizedBox(height: 10),

                            /// Option B
                            _QuizOption(
                              option: 'B',
                              text:
                                  'To increase internet connection speed and efficiency.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),

                BottomCTA(),
              ],
            ),
          ),
          if (showSidebar)
            RightSideBarOverlay(
              onClose: () {
                setState(() => showSidebar = false);
              },
            ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FeatureItem({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _QuizOption extends StatelessWidget {
  final String option;
  final String text;

  const _QuizOption({required this.option, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 266,
      height: 32,
      padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$option)',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
              fontFamily: 'roboto',
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 9.5,
                color: Color.fromARGB(255, 0, 0, 0),
                fontFamily: 'inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:grad_project/features/onboarding/screens/overlay.dart';
import 'package:grad_project/features/widgets/BottomCTA.dart';
import 'package:grad_project/features/widgets/howcard.dart';

class HowItWorks extends StatefulWidget {
  const HowItWorks({super.key});

  @override
  State<HowItWorks> createState() => _HowItWorksState();
}

class _HowItWorksState extends State<HowItWorks> {
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
            const Text(
              "How It Works",
              style: TextStyle(
                color: Color(0xFF163D69),
                fontSize: 18,
                fontWeight: FontWeight.w600,
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
                const SizedBox(height: 20),

                /// الصورة
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/meeting.jpg',
                    width: 344,
                    height: 252,

                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 25),

                /// العنوان
                const Text(
                  "How EduNexus Works",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 7),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "EduNexus empowers seamless interaction between students and educators through an intelligent learning platform.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(255, 110, 110, 110),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// الكروت
                Center(
                  child: SizedBox(
                    width: (164 * 2) + 15,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            mainAxisExtent: 158,
                          ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        final cards = [
                          FeatureCard(
                            imageicon: "assets/images/vcam.png",
                            title: "Start Meeting",
                            description:
                                "Join your meeting with confidence experience high quality connections.",
                            color: Color(0xFFD1E2F5),
                          ),
                          FeatureCard(
                            imageicon: "assets/images/AI.png",
                            title: "Speech To Text",
                            description:
                                "Our AI listens and translates audio to text.",
                            color: Color(0xFFFBC9FF),
                          ),
                          FeatureCard(
                            imageicon: "assets/images/qumark.png",
                            title: "Auto Quiz",
                            description:
                                "Our AI automatically creates simple and smart questions fastly",
                            color: Color(0xFFC8FFCC),
                          ),
                          FeatureCard(
                            imageicon: "assets/images/Group.png",
                            title: "Live Results",
                            description:
                                "this keeps you updated in real time ,see questions results and track progress",
                            color: Color(0xFFFFE8B1),
                          ),
                        ];
                        return cards[index];
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                BottomCTA(),
              ],
            ),
          ),

          if (showSidebar)
            RightSideBarOverlay(
              onClose: () {
                if (!mounted) return;
                setState(() => showSidebar = false);
              },
            ),
        ],
      ),
    );
  }
}

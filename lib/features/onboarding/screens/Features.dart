import 'package:flutter/material.dart';
import 'package:grad_project/features/onboarding/screens/overlay.dart';
import 'package:grad_project/features/widgets/BottomCTA.dart';
import 'package:grad_project/features/widgets/featurecard.dart';

class Features extends StatefulWidget {
  const Features({super.key});

  @override
  State<Features> createState() => _FeaturesState();
}

class _FeaturesState extends State<Features> {
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
              "Features",
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                /// العنوان
                const Center(
                  child: Text(
                    "Everything You Need, Completely Free",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 10),

                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      "Enjoy live classes, recorded lessons, and progress tracking — all free on EduAura.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// Show All
                const Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Show All",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// Grid الكروت
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.85,
                    children: [
                      FeatureBox(
                        icon: "assets/images/analytics.png",
                        title: "Live Analytics",
                        description:
                            "Instant feedback and student understanding and lesson effectiveness",
                        bordercolor: Color(0xFFDDB438),
                      ),
                      FeatureBox(
                        icon: "assets/images/device.png",
                        title: "Multi-Device Support",
                        description:
                            "Works on phone, tablets, laptops – students can join from anywhere.",
                        bordercolor: Color(0xff6D71C7),
                      ),
                      FeatureBox(
                        icon: "assets/images/video.png",
                        title: "Video Conferencing",
                        description:
                            "HD video calls, screen sharing, chat – everything you expect is here.",
                        bordercolor: Color(0xff4072AB),
                      ),
                      FeatureBox(
                        icon: "assets/images/AIquiz.png",
                        title: "AI Quiz Generator",
                        description:
                            "Automatically creates relevant questions based on your lesson.",
                        bordercolor: Color(0xff46E051),
                      ),
                    ],
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

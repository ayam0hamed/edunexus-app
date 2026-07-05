import 'package:flutter/material.dart';
import 'package:grad_project/features/onboarding/screens/overlay.dart';
import 'package:grad_project/features/widgets/BottomCTA.dart';
import 'package:grad_project/features/widgets/reviewcard.dart';
import 'package:grad_project/features/widgets/teamcards.dart';

class Aboutus extends StatefulWidget {
  const Aboutus({super.key});

  @override
  State<Aboutus> createState() => _AboutusState();
}

class _AboutusState extends State<Aboutus> {
  bool showSidebar = false;
  final List<Map<String, String>> teamMembers = [
    {
      "name": "Eslam Taha",
      "job": "Artificial Intelligence",
      "imageUrl": "assets/images/p1.png",
    },
    {
      "name": "Ali Hassan",
      "job": "Compiler Theory",
      "imageUrl": "assets/images/p2.png",
    },
    {
      "name": "Alice Johnson",
      "job": "Project Manager",
      "imageUrl": "assets/images/p3.jpg",
    },
  ];

  final List<Map<String, String>> reviews = [
    {
      "name": "Mohamed Ahmed",
      "review":
          "Using EduAura has been a great experience! The platform is super easy to use, smart, and really helps me stay engaged during classes. I love how everything runs smoothly.",
      "rating": "4.0",
      "imageUrl": "assets/images/review2.png",
    },
    {
      "name": "Joliana Hany",
      "review":
          "I’ve really enjoyed using this platform — it’s simple, smart, and saves me a lot of time. The interactive tools make learning fun, and the AI features feel like having a personal assistant in class.",
      "rating": "5.0",
      "imageUrl": "assets/images/review1.png",
    },
  ];

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
              "About Us",
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
            child: Center(
              child: Column(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/aboutus.png',
                        width: 341,
                        height: 227,

                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// العنوان
                  const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "About ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF163D69),
                          ),
                        ),
                        Text(
                          "EduNexus Platform",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE56C00),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "   EduNexus is a new, smart learning platform designed to make \neducation more interactive and inspiring. It connects teachers and\n learners through real-time communication, smart sharing tools, and\n AI-powered features.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'inter',
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/users.png',
                          width: 90,
                          height: 50,
                        ),
                        SizedBox(width: 16),
                        Text(
                          "10K+ Users",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "Our Team in EduNexus",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 150),
                            Text(
                              "Show All",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 22),
                        SizedBox(
                          height: 178,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3, // Replace with actual item count
                            itemBuilder: (context, index) {
                              final member = teamMembers[index];
                              final name = member['name'] ?? '';
                              final job = member['job'] ?? '';
                              final imageUrl = member['imageUrl'] ?? '';

                              return TeamCard(
                                name: name,
                                job: job,
                                imageUrl: imageUrl,
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 22),
                        Row(
                          children: [
                            Text(
                              "Loved by ",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: Color(0xff163D69),
                              ),
                            ),
                            Text(
                              "teams ",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              "around the World",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: Color(0xffE56C00),
                              ),
                            ),
                            SizedBox(width: 80),
                            Text(
                              "Show All",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          height: 170,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: 2,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 4),
                            itemBuilder: (context, index) {
                              return ReviewCard(
                                name: reviews[index]['name'] ?? '',
                                review: reviews[index]['review'] ?? '',
                                rating:
                                    double.tryParse(
                                      reviews[index]['rating'] ?? '0',
                                    ) ??
                                    0,
                                imagePath: reviews[index]['imageUrl'] ?? '',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  BottomCTA(),
                ],
              ),
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

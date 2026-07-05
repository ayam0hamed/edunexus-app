import 'package:flutter/material.dart';
import 'package:grad_project/features/widgets/button.dart';
import 'package:grad_project/features/widgets/privacycards.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Color.fromARGB(255, 94, 92, 95),

        elevation: 1,
        title: const Text(
          'Privacy Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF163D69),
            fontFamily: "poppins",
          ),
        ),
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Icon(Icons.privacy_tip, color: Colors.black, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Control Your Privacy",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: "poppins",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Manage your profile visibility and data sharing preferences. These settings help you control what information is shared with students and the platform.",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                  fontFamily: "poppins",
                ),
              ),
              const SizedBox(height: 25),
              Container(
                width: 347,
                height: 585,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFECECEC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Privacycards(
                      icon: Icons.language_sharp,
                      title: "Public Profile",
                      subtitle:
                          "Make your instructor profile visible to everyone",
                    ),
                    Privacycards(
                      icon: Icons.remove_red_eye_outlined,
                      title: "Profile Visiblity",
                      subtitle: "Show your profile to students and visitors",
                    ),
                    Privacycards(
                      icon: Icons.lock,
                      title: "Show Your Email",
                      subtitle: "Display your ssn on your public profile",
                    ),
                    Privacycards(
                      icon: Icons.menu_book_outlined,
                      title: "Show Course Registration",
                      subtitle:
                          "Display total number of courses that you registeres",
                    ),
                    Privacycards(
                      icon: Icons.visibility_off,
                      title: "Share Analytics Data",
                      subtitle: "Help us improve the platform with usage data",
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              GradientButton(
                width: 347,
                height: 48,
                borderRadius: 10,
                onPressed: () {},
                text: "Save Changes",
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontFamily: "inter",
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

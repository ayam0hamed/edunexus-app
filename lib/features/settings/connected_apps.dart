import 'package:flutter/material.dart';
import 'package:grad_project/features/widgets/Apps_card.dart';

class ConnectedAppsScreen extends StatelessWidget {
  const ConnectedAppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Color.fromARGB(255, 94, 92, 95),

        elevation: 1,
        title: const Text(
          'Connected Apps',
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.flash_on_sharp,
                    color: Colors.black,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Connected Apps",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: "poppins",
                    ),
                  ),
                ],
              ),
              Text(
                "Link your accounts for enhanced functionality and seamless integration.",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                  fontFamily: "poppins",
                ),
              ),
              const SizedBox(height: 25),
              Container(
                width: 343,
                height: 678,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFECECEC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    AppsCard(
                      label: "Google",
                      discription:
                          "Connect your Google account for easy sign-in and calendar integration",
                      cardcolor: const Color(0xFFF5EEFF),
                      bordercolor: const Color(0xFFBA8EF8),
                      icon: Image(
                        image: AssetImage("assets/images/google.png"),
                        height: 20,
                        width: 20,
                      ),
                    ),

                    const SizedBox(height: 24),
                    AppsCard(
                      label: "Microsoft",
                      discription:
                          "Connect your Microsoft account for seamless sign-in and Outlook calendar integration.",
                      cardcolor: const Color(0xFFFCF3D9),
                      bordercolor: const Color(0xFFFAC62F),
                      icon: Image(
                        image: AssetImage("assets/images/microsoft.png"),
                        height: 20,
                        width: 20,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppsCard(
                      label: "Zoom Meetings",
                      cardcolor: const Color(0xFFE3EEFF),
                      bordercolor: const Color(0xFF64A1FF),
                      discription:
                          "Connect your account to join Zoom meetings faster and keep your schedule organized",
                      icon: Image(
                        image: AssetImage("assets/images/zoom.png"),
                        height: 20,
                        width: 20,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppsCard(
                      label: "Google Meets",
                      discription:
                          "Connect your account to join Google meetings faster and keep your schedule organized",
                      cardcolor: const Color(0xFFE6F5E5),
                      bordercolor: const Color(0xFF72F869),
                      icon: Image(
                        image: AssetImage("assets/images/googlemeets.png"),
                        height: 20,
                        width: 20,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Container(
                height: 102,
                width: 343,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFE3EEFF),
                  border: Border.all(color: const Color(0xFF89B6FC)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        textAlign: TextAlign.left,
                        "About Connected Apps",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF163D69),
                          fontFamily: "inter",
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Connected apps can access certain information from your account. You can manage permissions or disconnect any app at any time. We recommend only connecting trusted applications",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF438DFF),
                        fontFamily: "inter",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

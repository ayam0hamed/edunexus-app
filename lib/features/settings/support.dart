import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Color.fromARGB(255, 94, 92, 95),
        elevation: 1,
        title: const Text(
          'Help & Support',
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
        padding: EdgeInsets.all(23),
        child: Column(
          children: [
            Container(
              height: 85,
              width: 347,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFDDFFFA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color(0xFF00F2FF)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 20),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),

                    child: Image.asset(
                      "assets/images/support.png",
                      height: 20,
                      width: 20,
                    ),
                  ),
                  SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Help & Support",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Find answers to common questions or\n contact our support team",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 35),
            Container(
              width: 347,
              height: 714,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFECECEC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Frequently Asked Questions",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  cards(
                    "How do I create a new account?",
                    "Accounts are created by your institution’s admin. Please contact your admin to set up your account. Once your account is created, you will receive an email with login details.",
                  ),
                  cards(
                    "Why can’t I join the live meeting?",
                    "Check your internet connection and make sure the meeting link is correct.  If the issue continues, refresh the page or rejoin the meeting.",
                  ),
                  cards(
                    "How do I report a problem or bug?",
                    "Go to Report a Problem, describe the issue, and attach screenshots if possible.This helps us solve the issue faster. ",
                  ),
                  cards(
                    "How can I edit my profile information?",
                    "Go to Profile Settings, and you can edit your name, and other details",
                  ),
                  cards(
                    "I forgot my password.What should I do?",
                    "Click on "
                        "Forgot Password,"
                        " enter the email linked to your account, and you will receive a link to reset your password.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget cards(String label, String details) {
  return Container(
    height: 100,
    width: 322,
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(10),
    ),

    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),

            Icon(Icons.keyboard_arrow_down_sharp, color: Colors.grey),
          ],
        ),

        Divider(thickness: 1, color: Colors.grey[300]),
        Text(
          details,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Color.fromARGB(255, 94, 92, 95),

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
              'Profile',
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
            const Text(
              'EduNexus',
              style: TextStyle(
                color: Color(0xFF003366),
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Header Card
            Container(
              height: 62,
              width: 352,
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: CircleAvatar(
                      maxRadius: 20,
                      child: Image.asset(
                        'assets/images/john.jpg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.person),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'John Games',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: "poppins",
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Name Row
            Row(
              children: [
                Expanded(child: _buildField('First Name', 'John')),
                const SizedBox(width: 16),
                Expanded(child: _buildField('Last Name', 'Games')),
              ],
            ),
            const SizedBox(height: 20),

            // SSN
            _buildField('SSN', '304010111234678'),
            const SizedBox(height: 20),

            // Level
            _buildField('Level', '4'),
            const SizedBox(height: 20),

            // Organization
            _buildField(
              'Organization',
              'Faculty of Computer and Information — Beni-Suef University',
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Related Links Section
            const Text(
              'Related Links',
              style: TextStyle(
                color: Color(0xFF003366),
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: "poppins",
              ),
            ),
            const SizedBox(height: 16),

            // Google Link
            _buildField('Google', 'johngames234@gmail.com'),
            const SizedBox(height: 20),

            // Microsoft Link
            _buildField('Microsoft', 'johngames890@outlook.com'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black87,
            fontFamily: "poppins",
          ),
        ),
        const SizedBox(height: 8),
        Container(
          color: Colors.grey[200],
          child: TextField(
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withOpacity(0.6),
            ),
            controller: TextEditingController(text: value),
            maxLines: maxLines,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFFB3B3B3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFFB3B3B3)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

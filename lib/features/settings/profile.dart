import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light background
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
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: First Name & Second Name
              Row(
                children: [
                  Expanded(child: _buildField('First Name', 'Mahmoud')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField('Second Name', 'Tarek')),
                ],
              ),
              const SizedBox(height: 16),

              // Row 2: Third Name & Last Name
              Row(
                children: [
                  Expanded(child: _buildField('Third Name', 'El')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField('Last Name', 'Masry')),
                ],
              ),
              const SizedBox(height: 16),

              // SSN
              _buildField(
                'SSN',
                '20000000000001',
                readOnly: true,
                helperText: 'SSN cannot be changed',
              ),
              const SizedBox(height: 16),

              // Phone Number
              _buildField('Phone Number', '+20-111-100-0001'),
              const SizedBox(height: 16),

              // Email
              _buildField('Email', 'm.elmasry@cu.edu.eg'),
              const SizedBox(height: 32),

              // Save Changes Button
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF324158), // Dark Blue
                      Color(0xFFD26F28), // Orange
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: "poppins",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String value, {
    int maxLines = 1,
    bool readOnly = false,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF4A5568),
            fontFamily: "poppins",
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          style: TextStyle(
            fontSize: 16,
            color: readOnly ? Colors.grey[600] : Colors.black87,
          ),
          controller: TextEditingController(text: value),
          maxLines: maxLines,
          readOnly: readOnly,
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly ? const Color(0xFFF0F0F0) : const Color(0xFFFAFAFA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

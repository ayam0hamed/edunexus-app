import 'package:flutter/material.dart';
import 'package:grad_project/features/widgets/button.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Color.fromARGB(255, 94, 92, 95),
        elevation: 1,
        title: const Text(
          'Report a Problem',
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
              padding: EdgeInsets.fromLTRB(10, 8, 6, 0),
              decoration: BoxDecoration(
                color: Color(0xFFDDFFFA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color(0xFF00F2FF)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 12),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),

                    child: Icon(Icons.info_outline, color: Color(0xFF00F2FF)),
                  ),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "We're here to help",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Let us know about any technical issues or course-\nrelated concerns. Our team will investigate and\n respond within 24 hours.",
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
                  SelectableTextButton(
                    text: "Technical Issue",
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        isSelected = !isSelected;
                      });
                    },
                  ),
                  SelectableTextButton(
                    text: "Quiz Issues",
                    isSelected: !isSelected,
                    onTap: () {
                      setState(() {
                        isSelected = !isSelected;
                      });
                    },
                  ),
                  SelectableTextButton(
                    text: "Platform Bug",
                    isSelected: !isSelected,
                    onTap: () {
                      setState(() {
                        isSelected = !isSelected;
                      });
                    },
                  ),
                  SelectableTextButton(
                    text: "Live meeting connection issues",
                    isSelected: !isSelected,
                    onTap: () {
                      setState(() {
                        isSelected = !isSelected;
                      });
                    },
                  ),
                  SelectableTextButton(
                    text: "Platform settings doesn’t save changes",
                    isSelected: !isSelected,
                    onTap: () {
                      setState(() {
                        isSelected = !isSelected;
                      });
                    },
                  ),
                  SelectableTextButton(
                    text: "Other",
                    isSelected: !isSelected,
                    onTap: () {
                      setState(() {
                        isSelected = !isSelected;
                      });
                    },
                  ),
                  Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontFamily: "poppins",
                    ),
                  ),
                  TextField(
                    cursorColor: Colors.grey,
                    maxLines: 5,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,

                      hintText: "Please describe your issue in detail...",
                      hintStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                        fontFamily: "poppins",
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            GradientButton(
              width: 347,
              height: 48,
              borderRadius: 10,
              onPressed: () {},
              text: "Submit Report",
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class SelectableTextButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableTextButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey[800],
        backgroundColor: isSelected ? Colors.white : const Color(0xFFFAE8B1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey, width: 1),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        height: 40,
        width: 320,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: "poppins",
          ),
        ),
      ),
    );
  }
}

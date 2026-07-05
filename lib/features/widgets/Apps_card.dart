import 'package:flutter/material.dart';
import 'package:grad_project/features/widgets/button.dart';

class AppsCard extends StatelessWidget {
  final String label;
  final String discription;
  final Color cardcolor;
  final Color bordercolor;
  final Image icon;

  const AppsCard({
    super.key,
    required this.label,
    required this.discription,
    required this.cardcolor,
    required this.bordercolor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      width: 320,
      decoration: BoxDecoration(
        color: cardcolor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bordercolor, width: 1),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: "poppins",
                ),
              ),
              Spacer(),
              Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
              Text(
                "Connected",
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 10, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            discription,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.grey[400],
              fontFamily: "inter",
            ),
          ),
          Spacer(),
          GradientButton(
            width: 110,
            height: 26,
            borderRadius: 8,
            onPressed: () {},
            text: "Disconnect",
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: "poppins",
            ),
          ),
        ],
      ),
    );
  }
}

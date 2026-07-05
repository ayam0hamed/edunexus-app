import 'package:flutter/material.dart';

class FeatureBox extends StatelessWidget {
  final String title;
  final String description;
  final Color bordercolor;
  final String icon;
  //final Color color;

  const FeatureBox({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    //required this.color,
    required this.bordercolor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bordercolor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          /// الدائرة الملونة
          SizedBox(
            width: 50,
            height: 50,
            child: Image.asset(icon, fit: BoxFit.contain),
          ),

          SizedBox(height: 15),

          /// العنوان
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          /// الوصف
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),

          const Spacer(),

          /// Free Forever
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check, color: Colors.green, size: 16),
              SizedBox(width: 5),
              Text(
                "Free Forever",
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

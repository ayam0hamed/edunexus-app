import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final double rating;
  final String review;

  const ReviewCard({
    Key? key,
    required this.imagePath,
    required this.name,
    required this.rating,
    required this.review,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0), // مسافة بين الكروت
      child: Container(
        width: 204,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFE56C00)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// الصف العلوي (الصورة + الاسم + التقييم)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// الصورة
                  ClipOval(
                    child: Image.asset(
                      imagePath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Colors.grey),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  /// الاسم + التقييم
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// الاسم
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: "poppins",
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        /// التقييم
                        Row(
                          children: [
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 4),

                            ...List.generate(rating.floor(), (index) {
                              return const Icon(
                                Icons.star,
                                color: Color(0xFFFFC800),
                                size: 14,
                              );
                            }),

                            if (rating % 1 != 0)
                              const Icon(
                                Icons.star_half,
                                color: Color(0xFFFFC800),
                                size: 14,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// النص
              Expanded(
                child: Text(
                  review,
                  style: TextStyle(
                    fontSize: 10,
                    height: 1,
                    fontWeight: FontWeight.w400,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

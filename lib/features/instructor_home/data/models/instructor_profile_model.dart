import 'package:equatable/equatable.dart';

class InstructorProfileModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String ssn;
  final String gender;
  final bool isActive;

  const InstructorProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.ssn,
    required this.gender,
    required this.isActive,
  });

  factory InstructorProfileModel.fromJson(Map<String, dynamic> json) {
    return InstructorProfileModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['userName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      ssn: json['ssn']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      isActive: json['isActive'] is bool 
          ? json['isActive'] as bool 
          : (json['isActive']?.toString().toLowerCase() == 'true'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'ssn': ssn,
      'gender': gender,
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phoneNumber,
        ssn,
        gender,
        isActive,
      ];
}

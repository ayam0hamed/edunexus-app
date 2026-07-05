import 'package:equatable/equatable.dart';

class StudentProfileModel extends Equatable {
  final String fullName;
  final String email;
  final String? welcomeText;
  final String? profileInfo;

  const StudentProfileModel({
    required this.fullName,
    required this.email,
    this.welcomeText,
    this.profileInfo,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      fullName: json['fullName']?.toString() ?? json['userName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      welcomeText: json['welcomeText']?.toString(),
      profileInfo: json['profileInfo']?.toString() ?? json['bio']?.toString(),
    );
  }

  @override
  List<Object?> get props => [fullName, email, welcomeText, profileInfo];
}

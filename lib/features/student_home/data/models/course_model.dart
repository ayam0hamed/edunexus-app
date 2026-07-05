import 'package:equatable/equatable.dart';

class CourseModel extends Equatable {
  final String id;
  final String name;

  const CourseModel({
    required this.id,
    required this.name,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id']?.toString() ?? json['courseId']?.toString() ?? '',
      name: json['name']?.toString() ?? json['courseName']?.toString() ?? json['title']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, name];
}


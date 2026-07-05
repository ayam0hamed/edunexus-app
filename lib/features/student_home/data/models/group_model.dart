import 'package:equatable/equatable.dart';

class GroupModel extends Equatable {
  final String? id;
  final String? courseName;
  final String? instructorName;
  final String? image;

  const GroupModel({this.id, this.courseName, this.instructorName, this.image});

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id']?.toString(),
      courseName: json['courseName']?.toString() ?? json['name']?.toString(),
      instructorName:
          json['instructorName']?.toString() ?? json['instructor']?.toString(),
      image: json['image']?.toString() ?? json['courseImage']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, courseName, instructorName, image];
}

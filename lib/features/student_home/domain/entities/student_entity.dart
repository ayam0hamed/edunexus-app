import 'package:equatable/equatable.dart';

import '../../data/models/group_model.dart';

class StudentEntity extends Equatable {
  final String fullName;
  final String? welcomeText;
  final List<GroupModel> groups;
  final List<dynamic>? meetings;

  const StudentEntity({
    required this.fullName,
    this.welcomeText,
    required this.groups,
    this.meetings,
  });

  @override
  List<Object?> get props => [fullName, welcomeText, groups, meetings];
}

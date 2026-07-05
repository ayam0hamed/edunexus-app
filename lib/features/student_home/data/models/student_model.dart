import 'package:equatable/equatable.dart';

import 'group_model.dart';

class StudentModel extends Equatable {
  final String fullName;
  final String? welcomeText;
  final List<GroupModel> groups;

  /// Per requirements: Upcoming meetings should be null initially.
  final List<dynamic>? meetings;

  const StudentModel({
    required this.fullName,
    this.welcomeText,
    required this.groups,
    this.meetings,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final groupsJson = json['groups'];
    final groups = <GroupModel>[];

    if (groupsJson is List) {
      groups.addAll(
        groupsJson.whereType<Map<String, dynamic>>().map(GroupModel.fromJson),
      );
    }

    final fullName =
        json['fullName']?.toString() ?? json['userName']?.toString() ?? '';
    final welcomeText = json['welcomeText']?.toString();

    // Requirement: Upcoming meetings list should be null.
    return StudentModel(
      fullName: fullName,
      welcomeText: welcomeText,
      groups: groups,
      meetings: null,
    );
  }

  @override
  List<Object?> get props => [fullName, welcomeText, groups, meetings];
}

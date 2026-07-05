import 'package:equatable/equatable.dart';
import 'student_profile_model.dart';
import 'course_model.dart';
import 'meeting_model.dart';

class DashboardModel extends Equatable {
  final StudentProfileModel profile;
  final List<CourseModel> courses;
  final List<MeetingModel> meetings;
  final int quizzesCount;
  final int meetingsCount;

  const DashboardModel({
    required this.profile,
    required this.courses,
    required this.meetings,
    this.quizzesCount = 0,
    this.meetingsCount = 0,
  });

  @override
  List<Object?> get props => [profile, courses, meetings, quizzesCount, meetingsCount];
}

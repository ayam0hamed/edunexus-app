import 'package:grad_project/features/student_home/data/models/student_profile_model.dart';
import 'package:grad_project/features/student_home/data/models/course_model.dart';
import 'package:grad_project/features/student_home/data/models/meeting_model.dart';
import 'package:grad_project/features/student_home/data/models/dashboard_model.dart';
import '../entities/student_entity.dart';

abstract class StudentRepository {
  Future<StudentEntity> getStudentProfile();
  Future<StudentProfileModel> getStudentProfileModel();
  Future<List<CourseModel>> getStudentCourses(String studentId);
  Future<List<MeetingModel>> getStudentMeetings(String studentId);
  Future<DashboardModel> getStudentDashboard(String studentId, {bool forceRefresh = false});
  void clearCache();
}

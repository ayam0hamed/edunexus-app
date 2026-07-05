import 'package:dio/dio.dart';
import 'package:grad_project/core/network/dio_client.dart';
import 'package:grad_project/core/error/exceptions.dart';
import 'package:grad_project/features/student_home/data/models/student_profile_model.dart';
import 'package:grad_project/features/student_home/data/models/course_model.dart';
import 'package:grad_project/features/student_home/data/models/meeting_model.dart';

abstract class StudentRemoteDatasource {
  static const String baseUrl = 'https://edunexus.runasp.net/';

  Future<StudentProfileModel> getStudentProfile();
  Future<List<CourseModel>> getStudentCourses(String studentId);
  Future<List<MeetingModel>> getStudentMeetings(String studentId);
  Future<int> getMeetingsCount();
}

class StudentRemoteDatasourceImpl implements StudentRemoteDatasource {
  final DioClient dioClient;

  StudentRemoteDatasourceImpl(this.dioClient);

  @override
  Future<StudentProfileModel> getStudentProfile() async {
    try {
      final response = await dioClient.dio.get('/api/Account/profile');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return StudentProfileModel.fromJson(data);
      }
      throw const ServerException('Invalid server response format');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final msg = e.response?.data?.toString() ?? e.message ?? 'Network error';

      if (statusCode == 401) {
        throw UnauthorizedException(msg);
      }
      throw ServerException(msg, statusCode: statusCode);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<CourseModel>> getStudentCourses(String studentId) async {
    try {
      final response = await dioClient.dio.get('/api/Students/$studentId');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final success = data['success'] as bool? ?? false;
        if (success) {
          final studentData = data['data'] as Map<String, dynamic>?;
          if (studentData != null) {
            final enrolledCourses = studentData['enrolledCourses'];
            if (enrolledCourses is List) {
              return enrolledCourses
                  .whereType<Map<String, dynamic>>()
                  .map(CourseModel.fromJson)
                  .toList();
            }
          }
        } else {
          final message = data['message']?.toString() ?? 'Failed to retrieve student';
          throw ServerException(message);
        }
      }
      return const [];
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final msg = e.response?.data?.toString() ?? e.message ?? 'Network error';

      if (statusCode == 401) {
        throw UnauthorizedException(msg);
      }
      throw ServerException(msg, statusCode: statusCode);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<int> getMeetingsCount() async {
    try {
      final response = await dioClient.dio.get('/api/Dashboard/meetings-count');
      final data = response.data;
      if (data is num) {
        return data.toInt();
      }
      if (data is String) {
        return int.tryParse(data) ?? 0;
      }
      if (data is Map<String, dynamic>) {
        final val = data['data'] ?? data['count'] ?? data['meetingsCount'];
        if (val is num) return val.toInt();
        if (val is String) return int.tryParse(val) ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final msg = e.response?.data?.toString() ?? e.message ?? 'Network error';

      if (statusCode == 401) {
        throw UnauthorizedException(msg);
      }
      throw ServerException(msg, statusCode: statusCode);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Unexpected error: ${e.toString()}');
    }
  }

  //==================== Meeting ===================>
  @override
  Future<List<MeetingModel>> getStudentMeetings(String studentId) async {
    try {
      final response = await dioClient.dio.get(
        '/api/Students/$studentId/meetings',
      );
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(MeetingModel.fromJson)
            .toList();
      }
      return const [];
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final msg = e.response?.data?.toString() ?? e.message ?? 'Network error';

      if (statusCode == 401) {
        throw UnauthorizedException(msg);
      }
      throw ServerException(msg, statusCode: statusCode);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Unexpected error: ${e.toString()}');
    }
  }
}

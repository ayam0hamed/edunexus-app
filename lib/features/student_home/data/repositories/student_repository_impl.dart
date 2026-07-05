import 'package:grad_project/core/error/exceptions.dart';
import 'package:grad_project/core/error/failures.dart';
import 'package:grad_project/features/student_home/data/models/student_profile_model.dart';
import 'package:grad_project/features/student_home/data/models/course_model.dart';
import 'package:grad_project/features/student_home/data/models/meeting_model.dart';
import 'package:grad_project/features/student_home/data/models/dashboard_model.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_remote_datasource.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDatasource remoteDatasource;
  DashboardModel? _cachedDashboard;

  StudentRepositoryImpl(this.remoteDatasource);

  @override
  Future<StudentEntity> getStudentProfile() async {
    try {
      final profile = await remoteDatasource.getStudentProfile();
      return StudentEntity(
        fullName: profile.fullName,
        welcomeText: profile.welcomeText,
        groups: const [],
        meetings: const [],
      );
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on TimeoutException catch (e) {
      throw NetworkFailure(e.message);
    } on AppException catch (e) {
      throw ServerFailure(e.message);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<StudentProfileModel> getStudentProfileModel() async {
    try {
      return await remoteDatasource.getStudentProfile();
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on TimeoutException catch (e) {
      throw NetworkFailure(e.message);
    } on AppException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<CourseModel>> getStudentCourses(String studentId) async {
    try {
      return await remoteDatasource.getStudentCourses(studentId);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on TimeoutException catch (e) {
      throw NetworkFailure(e.message);
    } on AppException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<MeetingModel>> getStudentMeetings(String studentId) async {
    try {
      return await remoteDatasource.getStudentMeetings(studentId);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on TimeoutException catch (e) {
      throw NetworkFailure(e.message);
    } on AppException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<DashboardModel> getStudentDashboard(String studentId, {bool forceRefresh = false}) async {
    if (_cachedDashboard != null && !forceRefresh) {
      debugPrint('StudentRepositoryImpl: Returning cached dashboard data');
      return _cachedDashboard!;
    }

    try {
      debugPrint('StudentRepositoryImpl: Fetching dashboard data in parallel');
      final results = await Future.wait([
        remoteDatasource.getStudentProfile(),
        remoteDatasource.getStudentCourses(studentId),
        remoteDatasource.getStudentMeetings(studentId).catchError((e) {
          debugPrint('StudentRepositoryImpl: Meetings endpoint failed. Using empty list: $e');
          return <MeetingModel>[];
        }),
        remoteDatasource.getMeetingsCount().catchError((e) {
          debugPrint('StudentRepositoryImpl: Meetings count endpoint failed: $e');
          return 0;
        }),
      ]);

      final profile = results[0] as StudentProfileModel;
      final courses = results[1] as List<CourseModel>;
      final meetings = results[2] as List<MeetingModel>;
      final meetingsCount = results[3] as int;

      final dashboard = DashboardModel(
        profile: profile,
        courses: courses,
        meetings: meetings,
        quizzesCount: 0,
        meetingsCount: meetingsCount,
      );

      _cachedDashboard = dashboard;
      return dashboard;
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on TimeoutException catch (e) {
      throw NetworkFailure(e.message);
    } on AppException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure('Dashboard loading failed: ${e.toString()}');
    }
  }

  @override
  void clearCache() {
    _cachedDashboard = null;
    debugPrint('StudentRepositoryImpl: Cache cleared');
  }
}

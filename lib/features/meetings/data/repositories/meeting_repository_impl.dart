import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:grad_project/core/error/exceptions.dart';
import 'package:grad_project/core/error/failures.dart';
import 'package:grad_project/core/network/dio_client.dart';
import 'package:grad_project/features/meetings/data/models/meeting_model.dart';
import 'package:grad_project/features/meetings/domain/repositories/meeting_repository.dart';
import 'package:grad_project/features/instructor_home/domain/repositories/instructor_repository.dart';

class MeetingRepositoryImpl implements MeetingRepository {
  final DioClient dioClient;
  final InstructorRepository instructorRepository;
  
  // In-memory list to store created meetings for the upcoming meetings list
  final List<MeetingModel> _meetings = [];

  MeetingRepositoryImpl({
    required this.dioClient,
    required this.instructorRepository,
  });

  // createMeeting has been removed as part of the Schedule Meeting feature cleanup.

  @override
  Future<int> getStudentsCount() async {
    try {
      final response = await dioClient.dio.get('/api/Dashboard/students-count');
      final data = response.data;
      if (data == null) return 0;
      if (data is num) return data.toInt();
      if (data is String) return int.tryParse(data) ?? 0;
      if (data is Map<String, dynamic>) {
        final val = data['data'] ?? data['count'] ?? data['studentsCount'];
        if (val is num) return val.toInt();
        if (val is String) return int.tryParse(val) ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      debugPrint('MeetingRepositoryImpl (Students Count): DioException: ${e.message}');
      _handleDioException(e);
    } catch (e) {
      debugPrint('MeetingRepositoryImpl (Students Count): Exception: ${e.toString()}');
      return 0; // Return fallback value 0 instead of crashing
    }
  }

  @override
  Future<int> getMeetingsCount() async {
    try {
      final response = await dioClient.dio.get('/api/Dashboard/meetings-count');
      final data = response.data;
      if (data == null) return 0;
      if (data is num) return data.toInt();
      if (data is String) return int.tryParse(data) ?? 0;
      if (data is Map<String, dynamic>) {
        final val = data['data'] ?? data['count'] ?? data['meetingsCount'];
        if (val is num) return val.toInt();
        if (val is String) return int.tryParse(val) ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      debugPrint('MeetingRepositoryImpl (Meetings Count): DioException: ${e.message}');
      _handleDioException(e);
    } catch (e) {
      debugPrint('MeetingRepositoryImpl (Meetings Count): Exception: ${e.toString()}');
      return 0; // Return fallback value 0 instead of crashing
    }
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final profile = await instructorRepository.getInstructorProfile(forceRefresh: false);
      return {'id': profile.id, 'fullName': profile.fullName};
    } catch (e) {
      debugPrint('MeetingRepositoryImpl (Profile): Exception: ${e.toString()}');
      
      // Fallback: try cached profile
      final cached = await instructorRepository.getCachedProfile();
      if (cached != null) {
        return {'id': cached.id, 'fullName': cached.fullName};
      }
      
      rethrow;
    }
  }

  @override
  List<MeetingModel> getMeetings() {
    return _meetings;
  }

  @override
  Future<void> deleteMeeting(String meetingId) async {
    debugPrint('MeetingRepositoryImpl: deleteMeeting is currently pending backend implementation');
  }

  // editMeeting has been removed as part of the Schedule Meeting feature cleanup.

  @override
  Future<void> uploadPdf(String meetingId, String filePath) async {
    debugPrint('MeetingRepositoryImpl: uploadPdf is currently pending backend implementation');
  }

  @override
  Future<void> startMeeting(String meetingId) async {
    debugPrint('MeetingRepositoryImpl: startMeeting is currently pending backend implementation');
  }

  // Helper helper exception converter
  Never _handleDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    String message = 'Server error occurred';

    if (data != null) {
      if (data is Map && data.containsKey('message')) {
        message = data['message']?.toString() ?? message;
      } else if (data is Map && data.containsKey('errors')) {
        // API Validation errors list/map
        final errors = data['errors'];
        if (errors is Map) {
          final firstErrorList = errors.values.first;
          if (firstErrorList is List && firstErrorList.isNotEmpty) {
            message = firstErrorList.first.toString();
          } else {
            message = errors.toString();
          }
        } else {
          message = errors.toString();
        }
      } else {
        message = data.toString();
      }
    } else {
      message = e.message ?? 'Network error';
    }

    if (statusCode == 401) {
      throw UnauthorizedException(message);
    } else {
      throw ServerException(message, statusCode: statusCode);
    }
  }
}

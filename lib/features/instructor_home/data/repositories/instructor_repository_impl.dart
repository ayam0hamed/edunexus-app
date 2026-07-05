import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:grad_project/core/error/exceptions.dart';
import 'package:grad_project/core/error/failures.dart';
import 'package:grad_project/features/instructor_home/data/datasources/instructor_remote_datasource.dart';
import 'package:grad_project/features/instructor_home/data/models/instructor_profile_model.dart';
import 'package:grad_project/features/instructor_home/domain/repositories/instructor_repository.dart';

class InstructorRepositoryImpl implements InstructorRepository {
  final InstructorRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  static const String _cachedUserIdKey = 'cached_instructor_id';
  static const String _cachedFullNameKey = 'cached_instructor_full_name';

  InstructorProfileModel? _cachedProfile;
  Future<InstructorProfileModel>? _pendingProfileFuture;

  InstructorRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<InstructorProfileModel> getInstructorProfile({bool forceRefresh = false}) async {
    // 1. If in-memory cache is present and we don't force refresh, return it
    if (_cachedProfile != null && !forceRefresh) {
      debugPrint('InstructorRepositoryImpl: Returning in-memory cached profile');
      return _cachedProfile!;
    }

    // 2. If there's an ongoing request, return the same future to prevent duplicate network calls
    if (_pendingProfileFuture != null) {
      debugPrint('InstructorRepositoryImpl: Reusing ongoing profile request');
      return _pendingProfileFuture!;
    }

    // 3. Otherwise, create a new request and cache its future
    _pendingProfileFuture = _fetchProfileRemote();

    try {
      final profile = await _pendingProfileFuture!;
      return profile;
    } finally {
      _pendingProfileFuture = null;
    }
  }

  Future<InstructorProfileModel> _fetchProfileRemote() async {
    try {
      debugPrint('InstructorRepositoryImpl: Fetching profile from remote datasource');
      final profile = await remoteDataSource.getInstructorProfile();
      
      // Update in-memory cache
      _cachedProfile = profile;

      // Update persistent secure storage cache
      try {
        await secureStorage.write(key: _cachedUserIdKey, value: profile.id);
        await secureStorage.write(key: _cachedFullNameKey, value: profile.fullName);
        debugPrint('InstructorRepositoryImpl: Saved userId and fullName to secure storage');
      } catch (e) {
        debugPrint('InstructorRepositoryImpl: Failed to save to secure storage: $e');
      }

      return profile;
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on TimeoutException catch (e) {
      throw NetworkFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on AppException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<InstructorProfileModel?> getCachedProfile() async {
    // Return in-memory cache if available
    if (_cachedProfile != null) {
      return _cachedProfile;
    }

    // Try to construct a minimal profile model from persistent secure storage
    try {
      final id = await secureStorage.read(key: _cachedUserIdKey);
      final fullName = await secureStorage.read(key: _cachedFullNameKey);
      if (id != null && fullName != null) {
        debugPrint('InstructorRepositoryImpl: Found cached instructor in secure storage');
        _cachedProfile = InstructorProfileModel(
          id: id,
          fullName: fullName,
          email: '',
          phoneNumber: '',
          ssn: '',
          gender: '',
          isActive: false,
        );
        return _cachedProfile;
      }
    } catch (e) {
      debugPrint('InstructorRepositoryImpl: Error reading secure storage: $e');
    }

    return null;
  }

  @override
  Future<void> clearCache() async {
    _cachedProfile = null;
    try {
      await secureStorage.delete(key: _cachedUserIdKey);
      await secureStorage.delete(key: _cachedFullNameKey);
      debugPrint('InstructorRepositoryImpl: Cache cleared');
    } catch (e) {
      debugPrint('InstructorRepositoryImpl: Error clearing cache: $e');
    }
  }
}

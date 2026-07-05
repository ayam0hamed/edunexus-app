import 'package:dio/dio.dart';
import 'package:grad_project/core/network/dio_client.dart';
import 'package:grad_project/core/error/exceptions.dart';
import 'package:grad_project/features/instructor_home/data/models/instructor_profile_model.dart';

abstract class InstructorRemoteDataSource {
  Future<InstructorProfileModel> getInstructorProfile();
}

class InstructorRemoteDataSourceImpl implements InstructorRemoteDataSource {
  final DioClient dioClient;

  InstructorRemoteDataSourceImpl(this.dioClient);

  @override
  Future<InstructorProfileModel> getInstructorProfile() async {
    try {
      final response = await dioClient.dio.get('/api/Account/profile');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return InstructorProfileModel.fromJson(data);
      }
      throw const ServerException('Invalid server response format');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final msg = e.response?.data?.toString() ?? e.message ?? 'Network error';

      if (statusCode == 401) {
        throw UnauthorizedException(msg);
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const TimeoutException('Connection timed out. Please try again.');
      }
      throw ServerException(msg, statusCode: statusCode);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Unexpected error: ${e.toString()}');
    }
  }
}

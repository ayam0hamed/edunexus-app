import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:grad_project/features/auth/data/services/jwt_service.dart';
import 'package:grad_project/core/error/failures.dart';
import '../../domain/repositories/student_repository.dart';
import 'student_dashboard_event.dart';
import 'student_dashboard_state.dart';

class StudentDashboardBloc extends Bloc<StudentDashboardEvent, StudentDashboardState> {
  final StudentRepository studentRepository;
  final AuthRepository authRepository;
  final JwtService jwtService;

  StudentDashboardBloc({
    required this.studentRepository,
    required this.authRepository,
    required this.jwtService,
  }) : super(const DashboardInitial()) {
    on<LoadDashboardEvent>(_onLoadDashboard);
    on<RefreshDashboardEvent>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboardEvent event,
    Emitter<StudentDashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    await _fetchDashboardData(emit, forceRefresh: false);
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboardEvent event,
    Emitter<StudentDashboardState> emit,
  ) async {
    await _fetchDashboardData(emit, forceRefresh: true);
  }

  Future<void> _fetchDashboardData(
    Emitter<StudentDashboardState> emit, {
    required bool forceRefresh,
  }) async {
    try {
      final token = await authRepository.getToken();
      if (token == null || token.isEmpty) {
        emit(const DashboardError('Session expired. Please log in again.'));
        return;
      }

      final userId = jwtService.getUserId(token);
      if (userId == null || userId.isEmpty) {
        emit(const DashboardError('Invalid session token. Student ID not found.'));
        return;
      }

      final dashboard = await studentRepository.getStudentDashboard(
        userId,
        forceRefresh: forceRefresh,
      );

      emit(DashboardLoaded(dashboard));
    } on Failure catch (e) {
      debugPrint('StudentDashboardBloc: Failure occurred: ${e.message}');
      emit(DashboardError(e.message));
    } catch (e) {
      debugPrint('StudentDashboardBloc: Unexpected error: $e');
      emit(const DashboardError('An unexpected error occurred. Please try again.'));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:grad_project/core/error/failures.dart';
import '../../domain/usecases/get_instructor_profile_usecase.dart';
import 'instructor_event.dart';
import 'instructor_state.dart';

class InstructorBloc extends Bloc<InstructorEvent, InstructorState> {
  final GetInstructorProfileUseCase getInstructorProfileUseCase;
  final AuthRepository authRepository;

  InstructorBloc({
    required this.getInstructorProfileUseCase,
    required this.authRepository,
  }) : super(const InstructorInitial()) {
    on<LoadInstructorProfileEvent>(_onLoadInstructorProfile);
  }

  Future<void> _onLoadInstructorProfile(
    LoadInstructorProfileEvent event,
    Emitter<InstructorState> emit,
  ) async {
    emit(const InstructorLoading());

    try {
      final token = await authRepository.getToken();
      if (token == null || token.isEmpty) {
        emit(const InstructorError('Session expired. Please log in again.'));
        return;
      }

      final profile = await getInstructorProfileUseCase(forceRefresh: event.forceRefresh);
      emit(InstructorLoaded(profile));
    } on Failure catch (e) {
      debugPrint('InstructorBloc: Failure occurred: ${e.message}');
      emit(InstructorError(e.message));
    } catch (e) {
      debugPrint('InstructorBloc: Unexpected error: $e');
      emit(const InstructorError('An unexpected error occurred. Please try again.'));
    }
  }
}

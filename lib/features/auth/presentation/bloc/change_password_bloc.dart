import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/models/change_password_request.dart';
import 'change_password_event.dart';
import 'change_password_state.dart';

class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final AuthRepository authRepository;

  ChangePasswordBloc({required this.authRepository})
      : super(const ChangePasswordInitial()) {
    on<ChangePasswordSubmitted>(_onChangePasswordSubmitted);
  }

  Future<void> _onChangePasswordSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    emit(const ChangePasswordLoading());
    try {
      final response = await authRepository.changePassword(
        ChangePasswordRequest(
          currentPassword: event.currentPassword,
          newPassword: event.newPassword,
          confirmPassword: event.confirmPassword,
        ),
      );

      if (response.success) {
        emit(ChangePasswordSuccess(
          message: response.message.isNotEmpty
              ? response.message
              : 'Password changed successfully.',
        ));
      } else {
        emit(ChangePasswordFailure(
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to change password.',
          errors: response.errors,
        ));
      }
    } catch (e) {
      emit(ChangePasswordFailure(message: e.toString()));
    }
  }
}

import 'package:equatable/equatable.dart';

sealed class ChangePasswordState extends Equatable {
  const ChangePasswordState();

  @override
  List<Object?> get props => [];
}

class ChangePasswordInitial extends ChangePasswordState {
  const ChangePasswordInitial();
}

class ChangePasswordLoading extends ChangePasswordState {
  const ChangePasswordLoading();
}

class ChangePasswordSuccess extends ChangePasswordState {
  final String message;

  const ChangePasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ChangePasswordFailure extends ChangePasswordState {
  final String message;
  final List<String>? errors;

  const ChangePasswordFailure({required this.message, this.errors});

  @override
  List<Object?> get props => [message, errors];
}

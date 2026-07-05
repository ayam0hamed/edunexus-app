import 'package:equatable/equatable.dart';
import '../../data/models/instructor_profile_model.dart';

sealed class InstructorState extends Equatable {
  const InstructorState();

  @override
  List<Object?> get props => [];
}

class InstructorInitial extends InstructorState {
  const InstructorInitial();
}

class InstructorLoading extends InstructorState {
  const InstructorLoading();
}

class InstructorLoaded extends InstructorState {
  final InstructorProfileModel profile;
  const InstructorLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class InstructorError extends InstructorState {
  final String message;
  const InstructorError(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';

import '../../domain/entities/student_entity.dart';

sealed class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {
  const StudentInitial();
}

class StudentLoading extends StudentState {
  const StudentLoading();
}

class StudentSuccess extends StudentState {
  final StudentEntity student;

  const StudentSuccess(this.student);

  @override
  List<Object?> get props => [student];
}

class StudentError extends StudentState {
  final String message;

  const StudentError(this.message);

  @override
  List<Object?> get props => [message];
}

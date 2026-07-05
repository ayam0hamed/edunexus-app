import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/error/failures.dart';

import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_repository.dart';
import 'student_state.dart';

class StudentCubit extends Cubit<StudentState> {
  final StudentRepository repository;

  StudentCubit({required this.repository}) : super(const StudentInitial());

  Future<void> loadStudentProfile() async {
    emit(const StudentLoading());
    try {
      final StudentEntity student = await repository.getStudentProfile();
      emit(StudentSuccess(student));
    } on Failure catch (f) {
      emit(StudentError(f.message));
    } catch (e) {
      emit(const StudentError('Something went wrong. Please try again later.'));
    }
  }
}

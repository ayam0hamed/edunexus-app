import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:grad_project/core/error/failures.dart';
import 'package:grad_project/features/student_home/domain/entities/student_entity.dart';
import 'package:grad_project/features/student_home/domain/repositories/student_repository.dart';
import 'package:grad_project/features/student_home/presentation/cubit/student_cubit.dart';
import 'package:grad_project/features/student_home/presentation/cubit/student_state.dart';

class MockStudentRepository extends Mock implements StudentRepository {}

void main() {
  late StudentCubit studentCubit;
  late MockStudentRepository mockStudentRepository;

  setUp(() {
    mockStudentRepository = MockStudentRepository();
    studentCubit = StudentCubit(repository: mockStudentRepository);
  });

  tearDown(() {
    studentCubit.close();
  });

  test('initial state should be StudentInitial', () {
    expect(studentCubit.state, const StudentInitial());
  });

  group('loadStudentProfile', () {
    const studentEntity = StudentEntity(
      fullName: 'Jane Doe',
      welcomeText: 'Welcome',
      groups: [],
    );

    blocTest<StudentCubit, StudentState>(
      'emits [StudentLoading, StudentSuccess] when repository profile load succeeds',
      build: () {
        when(() => mockStudentRepository.getStudentProfile())
            .thenAnswer((_) async => studentEntity);
        return studentCubit;
      },
      act: (cubit) => cubit.loadStudentProfile(),
      expect: () => const [
        StudentLoading(),
        StudentSuccess(studentEntity),
      ],
    );

    blocTest<StudentCubit, StudentState>(
      'emits [StudentLoading, StudentError] on Failure exception',
      build: () {
        when(() => mockStudentRepository.getStudentProfile())
            .thenThrow(ServerFailure('Connection lost'));
        return studentCubit;
      },
      act: (cubit) => cubit.loadStudentProfile(),
      expect: () => const [
        StudentLoading(),
        const StudentError('Connection lost'),
      ],
    );

    blocTest<StudentCubit, StudentState>(
      'emits [StudentLoading, StudentError] on generic exception',
      build: () {
        when(() => mockStudentRepository.getStudentProfile())
            .thenThrow(Exception('Unknown error'));
        return studentCubit;
      },
      act: (cubit) => cubit.loadStudentProfile(),
      expect: () => const [
        StudentLoading(),
        const StudentError('Something went wrong. Please try again later.'),
      ],
    );
  });
}

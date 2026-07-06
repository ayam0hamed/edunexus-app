import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:grad_project/core/error/exceptions.dart';
import 'package:grad_project/core/error/failures.dart';
import 'package:grad_project/features/student_home/data/datasources/student_remote_datasource.dart';
import 'package:grad_project/features/student_home/data/models/student_profile_model.dart';
import 'package:grad_project/features/student_home/data/models/course_model.dart';
import 'package:grad_project/features/student_home/data/models/meeting_model.dart';
import 'package:grad_project/features/student_home/data/repositories/student_repository_impl.dart';

class MockStudentRemoteDatasource extends Mock implements StudentRemoteDatasource {}

void main() {
  late StudentRepositoryImpl studentRepository;
  late MockStudentRemoteDatasource mockRemoteDatasource;

  setUp(() {
    mockRemoteDatasource = MockStudentRemoteDatasource();
    studentRepository = StudentRepositoryImpl(mockRemoteDatasource);
  });

  group('getStudentProfile', () {
    const profileModel = StudentProfileModel(
      fullName: 'John Doe',
      email: 'john@example.com',
      welcomeText: 'Welcome back!',
    );

    test('should return StudentEntity when profile fetch is successful', () async {
      // Arrange
      when(() => mockRemoteDatasource.getStudentProfile())
          .thenAnswer((_) async => profileModel);

      // Act
      final result = await studentRepository.getStudentProfile();

      // Assert
      expect(result.fullName, 'John Doe');
      expect(result.welcomeText, 'Welcome back!');
      verify(() => mockRemoteDatasource.getStudentProfile()).called(1);
    });

    test('should throw UnauthorizedFailure when UnauthorizedException occurs', () async {
      // Arrange
      when(() => mockRemoteDatasource.getStudentProfile())
          .thenThrow(const UnauthorizedException('Session expired'));

      // Act & Assert
      expect(
        () => studentRepository.getStudentProfile(),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });

    test('should throw ServerFailure when ServerException occurs', () async {
      // Arrange
      when(() => mockRemoteDatasource.getStudentProfile())
          .thenThrow(const ServerException('Internal Error'));

      // Act & Assert
      expect(
        () => studentRepository.getStudentProfile(),
        throwsA(isA<ServerFailure>()),
      );
    });
  });

  group('getStudentDashboard', () {
    const studentId = 'std-123';
    const profileModel = StudentProfileModel(
      fullName: 'John Doe',
      email: 'john@example.com',
      welcomeText: 'Welcome back!',
    );
    const courses = [CourseModel(id: 'c1', name: 'Math')];
    const meetings = [
      MeetingModel(
        id: 'm1',
        title: 'Session 1',
        description: 'First meeting',
        courseName: 'Math',
        date: '2026-07-10',
        time: '10:00 AM',
        duration: '60 mins',
        slotsInfo: '5/20',
        type: 'Lecture',
      )
    ];

    test('should return cached dashboard if cached and forceRefresh is false', () async {
      // Arrange
      when(() => mockRemoteDatasource.getStudentProfile())
          .thenAnswer((_) async => profileModel);
      when(() => mockRemoteDatasource.getStudentCourses(studentId))
          .thenAnswer((_) async => courses);
      when(() => mockRemoteDatasource.getStudentMeetings(studentId))
          .thenAnswer((_) async => meetings);
      when(() => mockRemoteDatasource.getMeetingsCount())
          .thenAnswer((_) async => 1);

      // Act: fetch twice
      final firstResult = await studentRepository.getStudentDashboard(studentId, forceRefresh: false);
      final secondResult = await studentRepository.getStudentDashboard(studentId, forceRefresh: false);

      // Assert
      expect(firstResult, secondResult);
      verify(() => mockRemoteDatasource.getStudentProfile()).called(1);
    });

    test('should call remote source if forceRefresh is true', () async {
      // Arrange
      when(() => mockRemoteDatasource.getStudentProfile())
          .thenAnswer((_) async => profileModel);
      when(() => mockRemoteDatasource.getStudentCourses(studentId))
          .thenAnswer((_) async => courses);
      when(() => mockRemoteDatasource.getStudentMeetings(studentId))
          .thenAnswer((_) async => meetings);
      when(() => mockRemoteDatasource.getMeetingsCount())
          .thenAnswer((_) async => 1);

      // Act
      await studentRepository.getStudentDashboard(studentId, forceRefresh: false);
      await studentRepository.getStudentDashboard(studentId, forceRefresh: true);

      // Assert
      verify(() => mockRemoteDatasource.getStudentProfile()).called(2);
    });

    test('should handle meetings and count endpoint failures and proceed with fallbacks', () async {
      // Arrange
      when(() => mockRemoteDatasource.getStudentProfile())
          .thenAnswer((_) async => profileModel);
      when(() => mockRemoteDatasource.getStudentCourses(studentId))
          .thenAnswer((_) async => courses);
      when(() => mockRemoteDatasource.getStudentMeetings(studentId))
          .thenAnswer((_) => Future<List<MeetingModel>>.error(const ServerException('Meetings service unavailable')));
      when(() => mockRemoteDatasource.getMeetingsCount())
          .thenAnswer((_) => Future<int>.error(const ServerException('Count service unavailable')));

      // Act
      final result = await studentRepository.getStudentDashboard(studentId, forceRefresh: true);

      // Assert
      expect(result.profile, profileModel);
      expect(result.courses, courses);
      expect(result.meetings, isEmpty); // Fallback to empty list
      expect(result.meetingsCount, 0); // Fallback to 0
    });
  });
}

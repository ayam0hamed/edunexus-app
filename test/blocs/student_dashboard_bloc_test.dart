import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:grad_project/core/error/failures.dart';
import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:grad_project/features/auth/data/services/jwt_service.dart';
import 'package:grad_project/features/student_home/domain/repositories/student_repository.dart';
import 'package:grad_project/features/student_home/presentation/bloc/student_dashboard_bloc.dart';
import 'package:grad_project/features/student_home/presentation/bloc/student_dashboard_event.dart';
import 'package:grad_project/features/student_home/presentation/bloc/student_dashboard_state.dart';
import 'package:grad_project/features/student_home/data/models/dashboard_model.dart';
import 'package:grad_project/features/student_home/data/models/student_profile_model.dart';

class MockStudentRepository extends Mock implements StudentRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockJwtService extends Mock implements JwtService {}

void main() {
  late StudentDashboardBloc dashboardBloc;
  late MockStudentRepository mockStudentRepository;
  late MockAuthRepository mockAuthRepository;
  late MockJwtService mockJwtService;

  setUp(() {
    mockStudentRepository = MockStudentRepository();
    mockAuthRepository = MockAuthRepository();
    mockJwtService = MockJwtService();

    dashboardBloc = StudentDashboardBloc(
      studentRepository: mockStudentRepository,
      authRepository: mockAuthRepository,
      jwtService: mockJwtService,
    );
  });

  tearDown(() {
    dashboardBloc.close();
  });

  test('initial state should be DashboardInitial', () {
    expect(dashboardBloc.state, const DashboardInitial());
  });

  group('LoadDashboardEvent', () {
    const dashboard = DashboardModel(
      profile: StudentProfileModel(fullName: 'John Doe', email: 'john@example.com'),
      courses: [],
      meetings: [],
      quizzesCount: 0,
      meetingsCount: 0,
    );

    blocTest<StudentDashboardBloc, StudentDashboardState>(
      'emits [DashboardLoading, DashboardLoaded] on success',
      build: () {
        when(() => mockAuthRepository.getToken()).thenAnswer((_) async => 'token123');
        when(() => mockJwtService.getUserId('token123')).thenReturn('user123');
        when(() => mockStudentRepository.getStudentDashboard('user123', forceRefresh: false))
            .thenAnswer((_) async => dashboard);
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(const LoadDashboardEvent()),
      expect: () => const [
        DashboardLoading(),
        DashboardLoaded(dashboard),
      ],
    );

    blocTest<StudentDashboardBloc, StudentDashboardState>(
      'emits [DashboardLoading, DashboardError] when token is null',
      build: () {
        when(() => mockAuthRepository.getToken()).thenAnswer((_) async => null);
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(const LoadDashboardEvent()),
      expect: () => const [
        DashboardLoading(),
        DashboardError('Session expired. Please log in again.'),
      ],
    );

    blocTest<StudentDashboardBloc, StudentDashboardState>(
      'emits [DashboardLoading, DashboardError] when dashboard fetch fails',
      build: () {
        when(() => mockAuthRepository.getToken()).thenAnswer((_) async => 'token123');
        when(() => mockJwtService.getUserId('token123')).thenReturn('user123');
        when(() => mockStudentRepository.getStudentDashboard('user123', forceRefresh: false))
            .thenThrow(ServerFailure('Network error'));
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(const LoadDashboardEvent()),
      expect: () => const [
        DashboardLoading(),
        DashboardError('Network error'),
      ],
    );
  });
}

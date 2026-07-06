import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grad_project/core/routing/app_routes.dart';
import 'package:grad_project/features/student_home/presentation/student_screen.dart';
import 'package:grad_project/features/student_home/presentation/bloc/student_dashboard_bloc.dart';
import 'package:grad_project/features/student_home/presentation/bloc/student_dashboard_event.dart';
import 'package:grad_project/features/student_home/presentation/bloc/student_dashboard_state.dart';
import 'package:grad_project/features/student_home/data/models/dashboard_model.dart';
import 'package:grad_project/features/student_home/data/models/student_profile_model.dart';
import 'package:grad_project/features/student_home/data/models/course_model.dart';
import 'package:grad_project/features/video_call/presentation/bloc/video_call/video_call_cubit.dart';
import 'package:grad_project/features/video_call/presentation/bloc/video_call/video_call_state.dart';

class MockStudentDashboardBloc extends MockBloc<StudentDashboardEvent, StudentDashboardState> implements StudentDashboardBloc {}
class MockVideoCallCubit extends MockCubit<VideoCallState> implements VideoCallCubit {}

void main() {
  late MockStudentDashboardBloc mockDashboardBloc;
  late MockVideoCallCubit mockVideoCallCubit;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    mockDashboardBloc = MockStudentDashboardBloc();
    mockVideoCallCubit = MockVideoCallCubit();

    // Register mocks to GetIt
    GetIt.I.registerFactory<StudentDashboardBloc>(() => mockDashboardBloc);
    GetIt.I.registerFactory<VideoCallCubit>(() => mockVideoCallCubit);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      routes: {
        AppRoutes.settings: (_) => const Scaffold(body: Text('Settings Screen')),
      },
      home: child,
    );
  }

  testWidgets('renders loading state correctly', (tester) async {
    // Arrange
    when(() => mockDashboardBloc.state).thenReturn(const DashboardLoading());

    // Act
    await tester.pumpWidget(buildTestableWidget(const StudentScreen()));

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders error state and triggers Try Again button', (tester) async {
    // Arrange
    when(() => mockDashboardBloc.state).thenReturn(const DashboardError('Fail to load data'));

    // Act
    await tester.pumpWidget(buildTestableWidget(const StudentScreen()));

    // Assert
    expect(find.text('Fail to load data'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    // Act: tap Try Again
    await tester.tap(find.text('Try Again'));
    await tester.pump();

    // Assert event dispatched
    verify(() => mockDashboardBloc.add(const RefreshDashboardEvent())).called(1);
  });

  testWidgets('renders loaded state and handles join meeting action', (tester) async {
    // Override the default size to fit all widgets on screen
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Arrange
    const dashboard = DashboardModel(
      profile: StudentProfileModel(
        fullName: 'Alice Smith',
        email: 'alice@example.com',
        welcomeText: 'Hi Alice!',
      ),
      courses: [CourseModel(id: 'course-1', name: 'Computer Science 101')],
      meetings: [],
      quizzesCount: 0,
      meetingsCount: 0,
    );

    when(() => mockDashboardBloc.state).thenReturn(const DashboardLoaded(dashboard));
    when(() => mockVideoCallCubit.state).thenReturn(const VideoCallInitial());
    when(() => mockVideoCallCubit.joinMeeting(any(), any())).thenAnswer((_) async {});

    // Act
    await tester.pumpWidget(buildTestableWidget(const StudentScreen()));
    await tester.pump();

    // Assert
    expect(find.text('Welcome back, Alice'), findsOneWidget);
    expect(find.text('Hi Alice!'), findsOneWidget);
    expect(find.text('Computer Science 101'), findsOneWidget);
    expect(find.text('Join Meeting'), findsOneWidget);

    // Enter meeting ID
    await tester.enterText(find.byType(TextField), 'meet-999');
    await tester.pump();

    // Tap Join Meeting
    await tester.tap(find.text('Join Meeting'));
    await tester.pump();

    // Assert VideoCallCubit method was called
    verify(() => mockVideoCallCubit.joinMeeting('meet-999', 'Alice Smith')).called(1);
  });
}

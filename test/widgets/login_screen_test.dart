import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grad_project/core/routing/app_routes.dart';
import 'package:grad_project/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grad_project/features/auth/presentation/bloc/auth_event.dart';
import 'package:grad_project/features/auth/presentation/bloc/auth_state.dart';
import 'package:grad_project/features/auth/presentation/screens/login_screen.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(const AppStarted());
    mockAuthBloc = MockAuthBloc();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      routes: {
        AppRoutes.forgetPassword: (_) => const Scaffold(body: Text('Forgot Password Screen')),
        AppRoutes.studentscreen: (_) => const Scaffold(body: Text('Student Screen')),
        AppRoutes.instructorScreen: (_) => const Scaffold(body: Text('Instructor Screen')),
      },
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: child,
      ),
    );
  }

  testWidgets('renders email/password fields and login button', (tester) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

    // Act
    await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

    // Assert
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('LOGIN NOW'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
  });

  testWidgets('shows validation errors when fields are empty', (tester) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

    // Act
    await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
    await tester.tap(find.text('LOGIN NOW'));
    await tester.pump();

    // Assert
    expect(find.text('Please enter your email or SSN'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
    verifyNever(() => mockAuthBloc.add(any()));
  });

  testWidgets('submits form with valid input', (tester) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

    // Act
    await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
    
    // Enter email/ssn
    await tester.enterText(find.byType(TextFormField).at(0), 'student@example.com');
    // Enter password (must be >= 6 characters)
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.pump();

    await tester.tap(find.text('LOGIN NOW'));
    await tester.pump();

    // Assert
    verify(() => mockAuthBloc.add(const LoginSubmitted(
      ssnOrEmail: 'student@example.com',
      password: 'password123',
      rememberMe: false,
    ))).called(1);
  });

  testWidgets('shows CircularProgressIndicator when state is AuthLoading', (tester) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(const AuthLoading());

    // Act
    await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('LOGIN NOW'), findsNothing);
  });

  testWidgets('shows SnackBar when state is AuthError', (tester) async {
    // Arrange
    final states = [const AuthInitial(), const AuthError('Invalid Credentials')];
    whenListen(mockAuthBloc, Stream.fromIterable(states), initialState: const AuthInitial());

    // Act
    await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
    await tester.pump(); // trigger the BlocListener

    // Assert
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Invalid Credentials'), findsOneWidget);
  });
}

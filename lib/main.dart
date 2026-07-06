import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_links/app_links.dart';
import 'package:grad_project/core/di/dependency_injection.dart';
import 'package:grad_project/core/routing/app_routes.dart';
import 'package:grad_project/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grad_project/features/auth/presentation/bloc/auth_event.dart';
import 'package:grad_project/features/auth/presentation/screens/check_email_screen.dart';
import 'package:grad_project/features/auth/presentation/screens/forget_password.dart';
import 'package:grad_project/features/auth/presentation/screens/new_password.dart';
import 'package:grad_project/features/onboarding/screens/landing.dart';
import 'package:grad_project/features/student_home/presentation/student_screen.dart';
import 'package:grad_project/features/settings/change_password.dart';
import 'package:grad_project/features/settings/connected_apps.dart';
import 'package:grad_project/features/auth/presentation/screens/logout.dart';
import 'package:grad_project/features/settings/lang.dart';
import 'package:grad_project/features/settings/privacy.dart';
import 'package:grad_project/features/settings/profile.dart';
import 'package:grad_project/features/settings/report.dart';
import 'package:grad_project/features/settings/settings.dart';
import 'package:grad_project/features/settings/support.dart';
import 'package:grad_project/features/instructor_home/presentation/screens/instructor_screen.dart';
import 'package:grad_project/features/meetings/presentation/screens/schedule_meeting_screen.dart';
import 'package:grad_project/features/meetings/presentation/bloc/meeting_bloc.dart';
import 'package:grad_project/features/meetings/presentation/bloc/meeting_event.dart';
import 'package:grad_project/features/video_call/presentation/screens/meeting_lobby_screen.dart';
import 'package:grad_project/features/video_call/presentation/screens/meeting_room_screen.dart';
import 'package:grad_project/features/video_call/presentation/bloc/video_call/video_call_cubit.dart';
import 'features/onboarding/screens/splash_screen.dart';
import 'features/onboarding/screens/Features.dart';
import 'features/onboarding/screens/how_itworks.dart';
import 'features/onboarding/screens/aboutus.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDI();
  runApp(const EduNexusApp());
}

class EduNexusApp extends StatefulWidget {
  const EduNexusApp({super.key});

  @override
  State<EduNexusApp> createState() => _EduNexusAppState();
}

class _EduNexusAppState extends State<EduNexusApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();
    
    // Check initial link if app was cold started by link
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }).catchError((err) {
      debugPrint('Deep Link Error: $err');
    });

    // Handle links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('Deep Link Stream Error: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Intercepted Deep Link: $uri');
    if (uri.scheme == 'myapp' && uri.host == 'reset-password') {
      final userId = uri.queryParameters['userId'];
      final token = uri.queryParameters['token'];
      if (userId != null && token != null) {
        // Delay slightly to ensure navigator is mounted
        Future.delayed(const Duration(milliseconds: 500), () {
          _navigatorKey.currentState?.pushNamed(
            AppRoutes.newPassword,
            arguments: {
              'userId': userId,
              'token': token,
            },
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrintRebuildDirtyWidgets = true;
    return BlocProvider<AuthBloc>(
      create: (_) => GetIt.I<AuthBloc>()..add(const AppStarted()),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'EduNexus Platform',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.splashScreen,
        routes: {
          AppRoutes.splashScreen: (context) => const SplashScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.landingPage: (context) => const LandingScreen(),
          AppRoutes.features: (context) => const Features(),
          AppRoutes.howItWorks: (context) => const HowItWorks(),
          AppRoutes.aboutUs: (context) => const Aboutus(),
          AppRoutes.studentscreen: (context) => const StudentScreen(),
          AppRoutes.instructorScreen: (context) => const InstructorScreen(),
          AppRoutes.settings: (context) => const SettingsScreen(),
          AppRoutes.changePassword: (context) => const ChangePassword(),
          AppRoutes.connectedApps: (context) => const ConnectedAppsScreen(),
          AppRoutes.profile: (context) => const ProfileScreen(),

          AppRoutes.languagePreferences: (context) =>
              const LanguagePreferencesScreen(),
          AppRoutes.privacySettings: (context) => const PrivacySettingsScreen(),
          AppRoutes.helpSupport: (context) => const HelpSupportScreen(),
          AppRoutes.reportProblem: (context) => const ReportProblemScreen(),
          AppRoutes.logout: (context) => const LogoutScreen(),
          AppRoutes.forgetPassword: (context) => const ForgetPassword(),
          AppRoutes.checkEmail: (context) => const CheckEmailScreen(),
          AppRoutes.newPassword: (context) => const NewPassword(),
          AppRoutes.scheduleMeeting: (context) => BlocProvider<MeetingBloc>(
            create: (_) => GetIt.I<MeetingBloc>()..add(const LoadMeetingsEvent()),
            child: const ScheduleMeetingScreen(),
          ),
          AppRoutes.meetingLobby: (context) => BlocProvider<VideoCallCubit>(
            create: (_) => GetIt.I<VideoCallCubit>(),
            child: const MeetingLobbyScreen(),
          ),
          AppRoutes.meetingRoom: (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            final meetingId = args['meetingId'] as String;
            final cubit = args['cubit'] as VideoCallCubit;
            return BlocProvider<VideoCallCubit>.value(
              value: cubit,
              child: MeetingRoomScreen(meetingId: meetingId),
            );
          },
        },
      ),
    );
  }
}

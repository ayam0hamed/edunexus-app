import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:grad_project/core/network/auth_interceptor.dart';
import 'package:grad_project/core/network/dio_client.dart';
import 'package:grad_project/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:grad_project/features/auth/data/services/jwt_service.dart';
import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:grad_project/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grad_project/features/auth/presentation/bloc/auth_event.dart';
import 'package:grad_project/features/auth/presentation/bloc/forgot_password_bloc.dart';
import 'package:grad_project/features/auth/presentation/bloc/reset_password_bloc.dart';
import 'package:grad_project/features/auth/presentation/bloc/change_password_bloc.dart';
import 'package:grad_project/features/student_home/data/datasources/student_remote_datasource.dart';
import 'package:grad_project/features/student_home/data/repositories/student_repository_impl.dart';
import 'package:grad_project/features/student_home/domain/repositories/student_repository.dart';
import 'package:grad_project/features/student_home/presentation/bloc/student_dashboard_bloc.dart';
import 'package:grad_project/features/meetings/domain/repositories/meeting_repository.dart';
import 'package:grad_project/features/meetings/data/repositories/meeting_repository_impl.dart';
import 'package:grad_project/features/meetings/presentation/bloc/meeting_bloc.dart';

// Instructor imports
import 'package:grad_project/features/instructor_home/data/datasources/instructor_remote_datasource.dart';
import 'package:grad_project/features/instructor_home/data/repositories/instructor_repository_impl.dart';
import 'package:grad_project/features/instructor_home/domain/repositories/instructor_repository.dart';
import 'package:grad_project/features/instructor_home/domain/usecases/get_instructor_profile_usecase.dart';
import 'package:grad_project/features/instructor_home/presentation/bloc/instructor_bloc.dart';

// Video Call imports
import 'package:grad_project/features/video_call/data/services/video_call_api_service.dart';
import 'package:grad_project/features/video_call/data/services/signalr_hub_service.dart';
import 'package:grad_project/features/video_call/data/services/webrtc_sfu_service.dart';
import 'package:grad_project/features/video_call/domain/repositories/video_call_repository.dart';
import 'package:grad_project/features/video_call/presentation/bloc/video_call/video_call_cubit.dart';
import 'package:grad_project/features/video_call/presentation/bloc/media/media_cubit.dart';
import 'package:grad_project/features/video_call/presentation/bloc/participants/participants_cubit.dart';
import 'package:grad_project/features/video_call/presentation/bloc/chat/chat_cubit.dart';
import 'package:grad_project/features/video_call/presentation/bloc/quiz/quiz_cubit.dart';
import 'package:grad_project/features/video_call/presentation/bloc/reactions/reactions_cubit.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // Secure Storage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  // JWT Service
  sl.registerLazySingleton<JwtService>(() => JwtService());

  // Interceptors
  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(
      secureStorage: sl(),
      onUnauthorized: () {
        if (sl.isRegistered<AuthBloc>()) {
          sl<AuthBloc>().add(const TokenExpired());
        }
      },
    ),
  );

  // Network client
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      baseUrl: 'https://edunexus.runasp.net',
      interceptors: [sl<AuthInterceptor>()],
    ),
  );

  // Auth Feature
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      dioClient: sl(),
      secureStorage: sl(),
      jwtService: sl(),
    ),
  );
  sl.registerFactory<AuthBloc>(() => AuthBloc(authRepository: sl()));
  sl.registerFactory<ForgotPasswordBloc>(() => ForgotPasswordBloc(authRepository: sl()));
  sl.registerFactory<ResetPasswordBloc>(() => ResetPasswordBloc(authRepository: sl()));
  sl.registerFactory<ChangePasswordBloc>(() => ChangePasswordBloc(authRepository: sl()));

  // Student Home Feature
  sl.registerLazySingleton<StudentRemoteDatasource>(
    () => StudentRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(sl()),
  );
  sl.registerFactory<StudentDashboardBloc>(
    () => StudentDashboardBloc(
      studentRepository: sl(),
      authRepository: sl(),
      jwtService: sl(),
    ),
  );

  // Instructor Home Feature
  sl.registerLazySingleton<InstructorRemoteDataSource>(
    () => InstructorRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<InstructorRepository>(
    () => InstructorRepositoryImpl(
      remoteDataSource: sl(),
      secureStorage: sl(),
    ),
  );
  sl.registerLazySingleton<GetInstructorProfileUseCase>(
    () => GetInstructorProfileUseCase(sl()),
  );
  sl.registerLazySingleton<InstructorBloc>(
    () => InstructorBloc(
      getInstructorProfileUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // Meetings Feature
  sl.registerLazySingleton<MeetingRepository>(
    () => MeetingRepositoryImpl(
      dioClient: sl(),
      instructorRepository: sl(),
    ),
  );
  sl.registerFactory<MeetingBloc>(
    () => MeetingBloc(meetingRepository: sl()),
  );

  // Video Call Feature
  sl.registerLazySingleton<VideoCallApiService>(
    () => VideoCallApiService(sl()),
  );
  sl.registerLazySingleton<SignalrHubService>(
    () => SignalrHubService(sl()),
  );
  sl.registerLazySingleton<WebrtcSfuService>(
    () => WebrtcSfuService(sl()),
  );
  sl.registerLazySingleton<VideoCallRepository>(
    () => VideoCallRepository(sl()),
  );
  
  sl.registerLazySingleton<VideoCallCubit>(
    () => VideoCallCubit(
      repository: sl(),
      hubService: sl(),
      sfuService: sl(),
      authRepository: sl(),
    ),
  );
  sl.registerFactory<MediaCubit>(
    () => MediaCubit(
      sfuService: sl(),
      hubService: sl(),
    ),
  );
  sl.registerFactory<ParticipantsCubit>(
    () => ParticipantsCubit(
      hubService: sl(),
      apiService: sl(),
    ),
  );
  sl.registerFactory<ChatCubit>(
    () => ChatCubit(
      hubService: sl(),
      apiService: sl(),
    ),
  );
  sl.registerFactory<QuizCubit>(
    () => QuizCubit(
      hubService: sl(),
      apiService: sl(),
    ),
  );
  sl.registerFactory<ReactionsCubit>(
    () => ReactionsCubit(
      hubService: sl(),
    ),
  );
}

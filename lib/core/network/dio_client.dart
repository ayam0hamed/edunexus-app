import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    List<Interceptor>? interceptors,
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: connectTimeout,
           receiveTimeout: receiveTimeout,
           headers: const {'Content-Type': 'application/json'},
         ),
       ) {
    if (interceptors != null) {
      dio.interceptors.addAll(interceptors);
    }
    // 🔍 Debug logging interceptor — remove in production or wrap with kDebugMode
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('┌─────────── 🚀 REQUEST ───────────');
          print('│ URL     : ${options.baseUrl}${options.path}');
          print('│ Method  : ${options.method}');
          print('│ Headers : ${options.headers}');
          print('│ Body    : ${options.data}');
          print('└──────────────────────────────────');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('┌─────────── ✅ RESPONSE ───────────');
          print('│ Status  : ${response.statusCode}');
          print('│ URL     : ${response.requestOptions.path}');
          print('│ Body    : ${response.data}');
          print('└──────────────────────────────────');
          handler.next(response);
        },
        onError: (DioException error, handler) {
          print('┌─────────── ❌ ERROR ──────────────');
          print('│ Type    : ${error.type}');
          print('│ URL     : ${error.requestOptions.path}');
          print('│ Status  : ${error.response?.statusCode}');
          print('│ Message : ${error.message}');
          print('│ Body    : ${error.response?.data}');
          print('│ Stack   : ${error.stackTrace}');
          print('└──────────────────────────────────');
          handler.next(error);
        },
      ),
    );
  }
}

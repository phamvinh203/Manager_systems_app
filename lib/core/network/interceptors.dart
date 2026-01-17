import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This interceptor is used to show request and response logs
class LoggerInterceptor extends Interceptor {
  Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
  );

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final requestPath = options.uri.toString();
    logger.e('${options.method} request ==> $requestPath'); //Error log
    logger.d(
      'Error type: ${err.error} \n '
      'Error message: ${err.message}',
    ); //Debug log
    if (err.response != null) {
      logger.d('Error Response Data: ${err.response?.data}');
    }
    handler.next(err); //Continue with the Error
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestPath = options.uri.toString();
    logger.i('${options.method} request ==> $requestPath'); //Info log
    handler.next(options); // continue with the Request
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d(
      'STATUSCODE: ${response.statusCode} \n '
      'STATUSMESSAGE: ${response.statusMessage} \n'
      'HEADERS: ${response.headers} \n'
      'Data: ${response.data}',
    ); // Debug log
    handler.next(response); // continue with the Response
  }
}

class AuthorizationInterceptor extends Interceptor {
  AuthorizationInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(
      'accessToken',
    ); // Đổi từ 'token' sang 'accessToken'

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;

    if (statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();

      // Token hết hạn hoặc không hợp lệ → xóa token
      await prefs.remove('accessToken'); // Đổi từ 'token' sang 'accessToken'
      await prefs.remove('refresh_token');

      Logger().w('401 Unauthorized - Token expired or invalid');

      // Thay đổi lỗi thành DioException đặc biệt để UI có thể nhận biết
      final error = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: DioExceptionType.badResponse,
        error: 'UNAUTHORIZED',
        message: 'Token expired or invalid',
      );

      return handler.next(error);
    }

    handler.next(err);
  }
}

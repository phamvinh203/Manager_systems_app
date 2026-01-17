import 'package:dio/dio.dart';
import 'package:mobile/core/network/dio_api.dart';
import 'package:mobile/core/storage/token_storage.dart';
import 'package:mobile/models/auth_model.dart';

class AuthRepository {
  final DioClient client;

  AuthRepository({DioClient? client}) : client = client ?? DioClient();

  Future<AuthResponse> login(String email, String password) async {
    try {
      final res = await client.post(
        'auth/login',
        data: {'email': email, 'password': password},
      );

      final auth = AuthResponse.fromJson(res.data);

      await TokenStorage.saveToken(auth.accessToken);
      await TokenStorage.saveUserId(auth.user.id);
      return auth;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<void> register(String fullName, String email, String password) async {
    try {
      await client.post(
        "auth/register",
        data: {"fullName": fullName, "email": email, "password": password},
      );
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // Helper: Extract error message from DioException
  String _getErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      return e.response?.data['message'] ?? e.message ?? 'Đã xảy ra lỗi';
    }
    return e.message ?? 'Đã xảy ra lỗi';
  }

  Future<void> logout() async {
    await TokenStorage.clearToken();
  }
}

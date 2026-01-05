import 'package:mobile/core/network/dio_api.dart';
import 'package:mobile/core/storage/token_storage.dart';
import 'package:mobile/models/auth_model.dart';

class AuthRepository {
  final DioClient client;

  AuthRepository({DioClient? client}) : client = client ?? DioClient();

  Future<AuthResponse> login(String email, String password) async {
    final res = await client.dio.post(
      'auth/login',
      data: {'email': email, 'password': password},
    );

    final auth = AuthResponse.fromJson(res.data);

    await TokenStorage.saveToken(auth.accessToken);
    return auth;
  }

  Future<void> register(String fullName, String email, String password) async {
    await client.dio.post(
      "auth/register",
      data: {"fullName": fullName, "email": email, "password": password},
    );
  }

  Future<void> logout() async {
    await TokenStorage.clearToken();
  }
}

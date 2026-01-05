import 'package:mobile/models/user_model.dart';

class AuthResponse {
  final String accessToken;
  final User user;
  final String? message;

  AuthResponse({required this.accessToken, required this.user, this.message});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'],
      user: User.fromJson(json['user']),
      message: json['message'],
    );
  }
}

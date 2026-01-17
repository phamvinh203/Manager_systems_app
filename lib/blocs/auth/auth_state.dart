import 'package:mobile/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final String accessToken;

  AuthAuthenticated({required this.user, required this.accessToken});

  // Helper methods kiểm tra quyền

  bool hasAnyRole(List<String> roles) => roles.contains(user.role);
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

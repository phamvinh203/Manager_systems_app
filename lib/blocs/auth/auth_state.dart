import 'package:mobile/models/auth_model.dart';
import 'package:mobile/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class AuthSuccess extends AuthState {
  final String message;
  final AuthResponse authResponse;
  AuthSuccess(this.message, this.authResponse);
}
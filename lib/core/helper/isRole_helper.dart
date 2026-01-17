import 'package:mobile/blocs/auth/auth_state.dart';
import 'package:mobile/models/user_model.dart';

extension UserRoleExtension on User {
  bool get isAdmin => role == 'ADMIN';
  bool get isHR => role == 'HR';
  bool get isManager => role == 'MANAGER';
  bool get isEmployee => role == 'EMPLOYEE';
}

extension AuthStateRoleExtension on AuthState {
  bool get isAdmin =>
      this is AuthAuthenticated && (this as AuthAuthenticated).user.isAdmin;
  bool get isHR =>
      this is AuthAuthenticated && (this as AuthAuthenticated).user.isHR;
  bool get isManager =>
      this is AuthAuthenticated && (this as AuthAuthenticated).user.isManager;
  bool get isEmployee =>
      this is AuthAuthenticated && (this as AuthAuthenticated).user.isEmployee;
}

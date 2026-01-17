import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:mobile/core/storage/token_storage.dart';
import 'package:mobile/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final Logger _logger = Logger();

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final auth = await authRepository.login(event.email, event.password);
      // Token đã được lưu trong repository
      emit(AuthAuthenticated(user: auth.user, accessToken: auth.accessToken));
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      _logger.e('Login error: $message');
      emit(AuthFailure(message));
    }
  }

  Future<void> _onRegister(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.register(
        event.fullName,
        event.email,
        event.password,
      );
      emit(AuthUnauthenticated());
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      _logger.e('Register error: $message');
      emit(AuthFailure(message));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await authRepository.logout();
      await TokenStorage.clearToken();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure("Logout failed"));
    }
  }
}

// lib/presentation/bloc/auth/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_parking_app/core/errors/failures.dart';
import 'package:smart_parking_app/domain/repositories/auth_repository.dart';
import 'package:smart_parking_app/presentation/bloc/auth/auth_event.dart';
import 'package:smart_parking_app/presentation/bloc/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<SignOutEvent>(_onSignOut);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<SendPasswordResetEvent>(_onSendPasswordReset);
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final isLoggedInResult = await authRepository.isLoggedIn();

    await isLoggedInResult.fold(
          (failure) async => emit(AuthError(message: failure.message)), // Made this async
          (isLoggedIn) async {
        if (isLoggedIn) {
          final userResult = await authRepository.getCurrentUser();

          // This inner fold is fine as both branches effectively return void
          userResult.fold(
                (failure) => emit(AuthError(message: failure.message)),
                (user) {
              if (user != null) {
                emit(Authenticated(user: user));
              } else {
                emit(Unauthenticated());
              }
            },
          );
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> _onSignIn(
      SignInEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await authRepository.signIn(
      event.email,
      event.password,
    );

    result.fold(
          (failure) => emit(AuthError(
        message: failure.message,
        code: (failure is AuthFailure) ? failure.code : null,
      )),
          (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onSignUp(
      SignUpEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await authRepository.signUp(
      event.email,
      event.password,
      event.name,
    );

    result.fold(
          (failure) => emit(AuthError(
        message: failure.message,
        code: (failure is AuthFailure) ? failure.code : null,
      )),
          (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onSignOut(
      SignOutEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await authRepository.signOut();

    result.fold(
          (failure) => emit(AuthError(message: failure.message)),
          (_) => emit(Unauthenticated()),
    );
  }

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(ProfileUpdateLoading());

    final result = await authRepository.updateProfile(
      name: event.name,
      phone: event.phone,
      photoUrl: event.photoUrl,
    );

    result.fold(
          (failure) => emit(AuthError(message: failure.message)),
          (user) => emit(ProfileUpdateSuccess(
        user: user,
        message: 'Profile updated successfully',
      )),
    );
  }

  Future<void> _onSendPasswordReset(
      SendPasswordResetEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await authRepository.sendPasswordResetEmail(event.email);

    result.fold(
          (failure) => emit(AuthError(message: failure.message)),
          (_) => emit(PasswordResetEmailSent(email: event.email)),
    );
  }
}
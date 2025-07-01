// lib/presentation/bloc/auth/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const SignUpEvent({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class SignOutEvent extends AuthEvent {}

class UpdateProfileEvent extends AuthEvent {
  final String? name;
  final String? phone;
  final String? photoUrl;

  const UpdateProfileEvent({
    this.name,
    this.phone,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [name, phone, photoUrl];
}

class SendPasswordResetEvent extends AuthEvent {
  final String email;

  const SendPasswordResetEvent({required this.email});

  @override
  List<Object?> get props => [email];
}
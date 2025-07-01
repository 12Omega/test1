// lib/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:smart_parking_app/core/errors/failures.dart';
import 'package:smart_parking_app/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Sign in user with email and password
  Future<Either<Failure, UserEntity>> signIn(String email, String password);
  
  /// Sign up a new user with email, password, and name
  Future<Either<Failure, UserEntity>> signUp(String email, String password, String name);
  
  /// Sign out the current user
  Future<Either<Failure, void>> signOut();
  
  /// Get the current logged in user
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  
  /// Check if a user is currently logged in
  Future<Either<Failure, bool>> isLoggedIn();
  
  /// Update user profile information
  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  });
  
  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
}
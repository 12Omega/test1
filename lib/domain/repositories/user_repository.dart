// lib/domain/repositories/user_repository.dart
import 'dart:async';
import '../entities/user_entity.dart';

abstract class UserRepository {
  // Authentication methods
  Future<UserEntity> signUp(String email, String password, String fullName, {String? phoneNumber});
  Future<UserEntity> signIn(String email, String password);
  Future<void> signOut();
  Future<bool> isSignedIn();
  Future<UserEntity?> getCurrentUser();
  
  // User profile methods
  Future<void> updateUserProfile(UserEntity user);
  Future<void> updatePassword(String currentPassword, String newPassword);
  Future<void> resetPassword(String email);
  
  // Favorites management
  Future<List<String>> getFavoriteSpots();
  Future<void> addFavoriteSpot(String spotId);
  Future<void> removeFavoriteSpot(String spotId);
}
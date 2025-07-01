// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:smart_parking_app/core/errors/exceptions.dart';
import 'package:smart_parking_app/domain/entities/user_entity.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  // For now, we'll just store users in memory since this is a mock
  final Map<String, UserEntity> _users = {};
  UserEntity? _currentUser;
  final Uuid _uuid = const Uuid();

  // Sign in a user
  Future<UserEntity> signIn(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock validation
    if (!_isValidEmail(email)) {
      throw AuthException(message: 'Invalid email format', code: 'invalid-email');
    }

    // Find the user with matching email (case insensitive)
    final user = _users.values.where(
      (u) => u.email.toLowerCase() == email.toLowerCase()
    ).firstOrNull;
    
    // Check if user exists and password is correct (in a real app, would use proper hashing)
    if (user == null) {
      throw AuthException(message: 'User not found', code: 'user-not-found');
    }
    
    // In a real app, we would hash the password and compare hashes
    // This is just a mockup for demonstration
    if (password != 'password123') { // Demo password for testing
      throw AuthException(message: 'Incorrect password', code: 'wrong-password');
    }
    
    _currentUser = user;
    return user;
  }

  // Sign up a new user
  Future<UserEntity> signUp(String email, String password, String name) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock validation
    if (!_isValidEmail(email)) {
      throw AuthException(message: 'Invalid email format', code: 'invalid-email');
    }
    
    if (password.length < 6) {
      throw AuthException(message: 'Password should be at least 6 characters', code: 'weak-password');
    }
    
    // Check if email is already in use
    if (_users.values.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      throw AuthException(message: 'Email already in use', code: 'email-already-in-use');
    }
    
    // Create new user
    final newUser = UserEntity(
      id: _uuid.v4(),
      name: name,
      email: email,
      phone: '',
      photoUrl: '',
    );
    
    // Save user to our mock database
    _users[newUser.id] = newUser;
    _currentUser = newUser;
    
    return newUser;
  }

  // Sign out the current user
  Future<void> signOut() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  // Get the current user
  Future<UserEntity?> getCurrentUser() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }

  // Check if a user is logged in
  Future<bool> isLoggedIn() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentUser != null;
  }

  // Update user profile
  Future<UserEntity> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (_currentUser == null) {
      throw AuthException(message: 'No user is logged in', code: 'no-user');
    }
    
    // Update user data
    final updatedUser = UserEntity(
      id: _currentUser!.id,
      name: name ?? _currentUser!.name,
      email: _currentUser!.email,
      phone: phone ?? _currentUser!.phone,
      photoUrl: photoUrl ?? _currentUser!.photoUrl,
    );
    
    // Save updated user
    _users[updatedUser.id] = updatedUser;
    _currentUser = updatedUser;
    
    return updatedUser;
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (!_isValidEmail(email)) {
      throw AuthException(message: 'Invalid email format', code: 'invalid-email');
    }
    
    // Check if email exists
    if (!_users.values.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      // Note: For security reasons, in a real app we would still return success
      // even if the email doesn't exist, but for our mock we'll throw an error
      throw AuthException(message: 'User not found', code: 'user-not-found');
    }
    
    // In a real app, this would send an actual email
    // For our mock, we just return success
    return;
  }

  // Helper method to validate email format
  bool _isValidEmail(String email) {
    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
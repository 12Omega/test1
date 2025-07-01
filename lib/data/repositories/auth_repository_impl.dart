// lib/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_parking_app/core/errors/exceptions.dart';
import 'package:smart_parking_app/core/errors/failures.dart';
import 'package:smart_parking_app/data/models/user_model.dart';
import 'package:smart_parking_app/domain/entities/user_entity.dart';
import 'package:smart_parking_app/domain/repositories/auth_repository.dart';
import 'package:smart_parking_app/services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;
  final SharedPreferences sharedPreferences;
  
  static const String USER_KEY = 'USER_DATA';

  AuthRepositoryImpl({
    required this.authService,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, UserEntity>> signIn(String email, String password) async {
    try {
      final user = await authService.signIn(email, password);
      
      // Save user data to local storage
      await _cacheUserData(UserModel.fromEntity(user));
      
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp(String email, String password, String name) async {
    try {
      final user = await authService.signUp(email, password, name);
      
      // Save user data to local storage
      await _cacheUserData(UserModel.fromEntity(user));
      
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await authService.signOut();
      
      // Clear cached user data
      await sharedPreferences.remove(USER_KEY);
      
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      // Try to get from service first (for most up-to-date data)
      final user = await authService.getCurrentUser();
      
      if (user != null) {
        // Update cached data
        await _cacheUserData(UserModel.fromEntity(user));
        return Right(user);
      }
      
      // If no user from service, try to get from local storage
      final cachedUser = _getCachedUserData();
      return Right(cachedUser);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await authService.isLoggedIn();
      return Right(isLoggedIn);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      final user = await authService.updateProfile(
        name: name,
        phone: phone,
        photoUrl: photoUrl,
      );
      
      // Update cached user data
      await _cacheUserData(UserModel.fromEntity(user));
      
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await authService.sendPasswordResetEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // Helper methods for caching
  Future<void> _cacheUserData(UserModel user) async {
    await sharedPreferences.setString(USER_KEY, user.toJson());
  }

  UserEntity? _getCachedUserData() {
    final jsonString = sharedPreferences.getString(USER_KEY);
    if (jsonString == null) return null;
    
    try {
      return UserModel.fromJson(jsonString);
    } catch (e) {
      return null;
    }
  }
}
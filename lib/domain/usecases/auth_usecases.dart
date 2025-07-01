// lib/domain/usecases/auth_usecases.dart
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class SignUpUseCase {
  final UserRepository repository;

  SignUpUseCase(this.repository);

  Future<UserEntity> execute(String email, String password, String fullName, {String? phoneNumber}) {
    return repository.signUp(email, password, fullName, phoneNumber: phoneNumber);
  }
}

class SignInUseCase {
  final UserRepository repository;

  SignInUseCase(this.repository);

  Future<UserEntity> execute(String email, String password) {
    return repository.signIn(email, password);
  }
}

class SignOutUseCase {
  final UserRepository repository;

  SignOutUseCase(this.repository);

  Future<void> execute() {
    return repository.signOut();
  }
}

class IsSignedInUseCase {
  final UserRepository repository;

  IsSignedInUseCase(this.repository);

  Future<bool> execute() {
    return repository.isSignedIn();
  }
}

class GetCurrentUserUseCase {
  final UserRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<UserEntity?> execute() {
    return repository.getCurrentUser();
  }
}

class UpdateUserProfileUseCase {
  final UserRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<void> execute(UserEntity user) {
    return repository.updateUserProfile(user);
  }
}

class UpdatePasswordUseCase {
  final UserRepository repository;

  UpdatePasswordUseCase(this.repository);

  Future<void> execute(String currentPassword, String newPassword) {
    return repository.updatePassword(currentPassword, newPassword);
  }
}

class ResetPasswordUseCase {
  final UserRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> execute(String email) {
    return repository.resetPassword(email);
  }
}

class GetFavoriteSpotsUseCase {
  final UserRepository repository;

  GetFavoriteSpotsUseCase(this.repository);

  Future<List<String>> execute() {
    return repository.getFavoriteSpots();
  }
}

class AddFavoriteSpotUseCase {
  final UserRepository repository;

  AddFavoriteSpotUseCase(this.repository);

  Future<void> execute(String spotId) {
    return repository.addFavoriteSpot(spotId);
  }
}

class RemoveFavoriteSpotUseCase {
  final UserRepository repository;

  RemoveFavoriteSpotUseCase(this.repository);

  Future<void> execute(String spotId) {
    return repository.removeFavoriteSpot(spotId);
  }
}
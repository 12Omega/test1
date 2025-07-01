// lib/core/errors/failures.dart

abstract class Failure {
  final String message;
  
  Failure({required this.message});
}

class ServerFailure extends Failure {
  final int? statusCode;
  
  ServerFailure({required String message, this.statusCode}) 
    : super(message: message);
}

class CacheFailure extends Failure {
  CacheFailure({required String message}) 
    : super(message: message);
}

class LocationFailure extends Failure {
  LocationFailure({required String message}) 
    : super(message: message);
}

class AuthFailure extends Failure {
  final String? code;
  
  AuthFailure({required String message, this.code}) 
    : super(message: message);
}

class BookingFailure extends Failure {
  BookingFailure({required String message}) 
    : super(message: message);
}

class NetworkFailure extends Failure {
  NetworkFailure({required String message}) 
    : super(message: message);
}
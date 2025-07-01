// lib/core/errors/exceptions.dart

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class LocationException implements Exception {
  final String message;

  LocationException({required this.message});

  @override
  String toString() => 'LocationException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException({required this.message, this.code});

  @override
  String toString() => 'AuthException: $message (Code: $code)';
}

class BookingException implements Exception {
  final String message;

  BookingException({required this.message});

  @override
  String toString() => 'BookingException: $message';
}
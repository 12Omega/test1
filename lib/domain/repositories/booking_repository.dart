// lib/domain/repositories/booking_repository.dart
import 'package:dartz/dartz.dart';
import 'package:smart_parking_app/core/errors/failures.dart';
import 'package:smart_parking_app/domain/entities/booking_entity.dart';

abstract class BookingRepository {
  /// Create a new booking
  Future<Either<Failure, BookingEntity>> createBooking({
    required String parkingSpotId,
    required String parkingSpotName,
    required DateTime startTime,
    required DateTime endTime,
    required String vehicleType,
    required String vehiclePlate,
    required double amount,
  });

  /// Get all bookings for the current user
  Future<Either<Failure, List<BookingEntity>>> getUserBookings();
  
  /// Get booking details by ID
  Future<Either<Failure, BookingEntity>> getBookingById(String id);
  
  /// Update booking status (e.g., cancel, complete)
  Future<Either<Failure, BookingEntity>> updateBookingStatus(String id, BookingStatus status);
  
  /// Get active bookings (ongoing)
  Future<Either<Failure, List<BookingEntity>>> getActiveBookings();
  
  /// Get upcoming bookings (not started yet)
  Future<Either<Failure, List<BookingEntity>>> getUpcomingBookings();
  
  /// Get past bookings (completed or expired)
  Future<Either<Failure, List<BookingEntity>>> getPastBookings();
}
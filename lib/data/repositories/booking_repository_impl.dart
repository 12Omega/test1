// lib/data/repositories/booking_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:smart_parking_app/core/errors/exceptions.dart';
import 'package:smart_parking_app/core/errors/failures.dart';
import 'package:smart_parking_app/domain/entities/booking_entity.dart';
import 'package:smart_parking_app/domain/repositories/booking_repository.dart';
import 'package:smart_parking_app/services/booking_service.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingService bookingService;

  BookingRepositoryImpl({
    required this.bookingService,
  });

  @override
  Future<Either<Failure, BookingEntity>> createBooking({
    required String parkingSpotId,
    required String parkingSpotName,
    required DateTime startTime,
    required DateTime endTime,
    required String vehicleType,
    required String vehiclePlate,
    required double amount,
  }) async {
    try {
      final booking = await bookingService.createBooking(
        parkingSpotId: parkingSpotId,
        parkingSpotName: parkingSpotName,
        startTime: startTime,
        endTime: endTime,
        vehicleType: vehicleType,
        vehiclePlate: vehiclePlate,
        amount: amount,
      );
      return Right(booking);
    } on BookingException catch (e) {
      return Left(BookingFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getUserBookings() async {
    try {
      final bookings = await bookingService.getUserBookings();
      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> getBookingById(String id) async {
    try {
      final booking = await bookingService.getBookingById(id);
      return Right(booking);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> updateBookingStatus(
      String id, BookingStatus status) async {
    try {
      final booking = await bookingService.updateBookingStatus(id, status);
      return Right(booking);
    } on BookingException catch (e) {
      return Left(BookingFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getActiveBookings() async {
    try {
      final bookings = await bookingService.getActiveBookings();
      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getUpcomingBookings() async {
    try {
      final bookings = await bookingService.getUpcomingBookings();
      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getPastBookings() async {
    try {
      final bookings = await bookingService.getPastBookings();
      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
// lib/domain/usecases/booking_usecases.dart
import 'package:dartz/dartz.dart';
import 'package:smart_parking_app/core/errors/failures.dart';
import '../entities/booking_entity.dart';
// BookingStatus enum is now available via booking_entity.dart
import '../repositories/booking_repository.dart';

class CreateBookingUseCase {
  final BookingRepository repository;

  CreateBookingUseCase(this.repository);

  Future<Either<Failure, BookingEntity>> execute({
    required String parkingSpotId,
    required String parkingSpotName,
    required DateTime startTime,
    required DateTime endTime,
    required String vehicleType,
    required String vehiclePlate,
    required double amount,
  }) {
    return repository.createBooking(
      parkingSpotId: parkingSpotId,
      parkingSpotName: parkingSpotName,
      startTime: startTime,
      endTime: endTime,
      vehicleType: vehicleType,
      vehiclePlate: vehiclePlate,
      amount: amount,
    );
  }
}

class GetUserBookingsUseCase {
  final BookingRepository repository;

  GetUserBookingsUseCase(this.repository);

  Future<Either<Failure, List<BookingEntity>>> execute() {
    return repository.getUserBookings();
  }
}

class GetBookingByIdUseCase {
  final BookingRepository repository;

  GetBookingByIdUseCase(this.repository);

  Future<Either<Failure, BookingEntity>> execute(String id) {
    return repository.getBookingById(id);
  }
}

class UpdateBookingStatusUseCase {
  final BookingRepository repository;

  UpdateBookingStatusUseCase(this.repository);

  Future<Either<Failure, BookingEntity>> execute(String id, BookingStatus status) {
    // Assuming updateBookingStatus in repository returns Either<Failure, BookingEntity>
    // The error log did not specify this one, but it's a likely pattern.
    // If it's void, this needs to be Future<Either<Failure, void>> or handle differently.
    // For now, let's assume it returns the updated entity.
    return repository.updateBookingStatus(id, status);
  }
}

class CancelBookingUseCase {
  final BookingRepository repository;

  CancelBookingUseCase(this.repository);

  Future<Either<Failure, void>> execute(String id) {
    return repository.cancelBooking(id);
  }
}

class ProcessPaymentUseCase {
  final BookingRepository repository;

  ProcessPaymentUseCase(this.repository);

  Future<Either<Failure, bool>> execute(String bookingId, String paymentMethod, {Map<String, dynamic>? paymentDetails}) {
    return repository.processPayment(bookingId, paymentMethod, paymentDetails: paymentDetails);
  }
}

class CalculateBookingAmountUseCase {
  final BookingRepository repository;

  CalculateBookingAmountUseCase(this.repository);

  Future<Either<Failure, double>> execute(String spotId, DateTime startTime, DateTime endTime) {
    return repository.calculateBookingAmount(spotId, startTime, endTime);
  }
}

class GetBookingStatisticsUseCase {
  final BookingRepository repository;

  GetBookingStatisticsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> execute(DateTime startDate, DateTime endDate) {
    return repository.getBookingStatistics(startDate, endDate);
  }
}
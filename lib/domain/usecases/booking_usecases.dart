// lib/domain/usecases/booking_usecases.dart
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class CreateBookingUseCase {
  final BookingRepository repository;

  CreateBookingUseCase(this.repository);

  Future<BookingEntity> execute({
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

  Future<List<BookingEntity>> execute() {
    return repository.getUserBookings();
  }
}

class GetBookingByIdUseCase {
  final BookingRepository repository;

  GetBookingByIdUseCase(this.repository);

  Future<BookingEntity> execute(String id) {
    return repository.getBookingById(id);
  }
}

class UpdateBookingStatusUseCase {
  final BookingRepository repository;

  UpdateBookingStatusUseCase(this.repository);

  Future<void> execute(String id, BookingStatus status) {
    return repository.updateBookingStatus(id, status);
  }
}

class CancelBookingUseCase {
  final BookingRepository repository;

  CancelBookingUseCase(this.repository);

  Future<void> execute(String id) {
    return repository.cancelBooking(id);
  }
}

class ProcessPaymentUseCase {
  final BookingRepository repository;

  ProcessPaymentUseCase(this.repository);

  Future<bool> execute(String bookingId, String paymentMethod, {Map<String, dynamic>? paymentDetails}) {
    return repository.processPayment(bookingId, paymentMethod, paymentDetails: paymentDetails);
  }
}

class CalculateBookingAmountUseCase {
  final BookingRepository repository;

  CalculateBookingAmountUseCase(this.repository);

  Future<double> execute(String spotId, DateTime startTime, DateTime endTime) {
    return repository.calculateBookingAmount(spotId, startTime, endTime);
  }
}

class GetBookingStatisticsUseCase {
  final BookingRepository repository;

  GetBookingStatisticsUseCase(this.repository);

  Future<Map<String, dynamic>> execute(DateTime startDate, DateTime endDate) {
    return repository.getBookingStatistics(startDate, endDate);
  }
}
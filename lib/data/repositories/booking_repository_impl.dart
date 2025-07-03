// lib/data/repositories/booking_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:smart_parking_app/core/errors/failures.dart';
import 'package:smart_parking_app/domain/entities/booking_entity.dart' as domain_entity; // Aliased
import 'package:smart_parking_app/domain/repositories/booking_repository.dart';
import 'package:smart_parking_app/services/booking_service.dart';
import 'package:smart_parking_app/models/booking.dart' as booking_model;

// --- Helper Functions for Model-Entity Conversion ---

domain_entity.BookingEntity _mapBookingModelToEntity(booking_model.Booking model) {
  return domain_entity.BookingEntity(
    id: model.id,
    parkingSpotId: model.parkingSpotId,
    parkingSpotName: model.parkingSpotName,
    startTime: model.startTime,
    endTime: model.endTime,
    vehicleType: model.vehicleType,
    vehiclePlate: model.vehiclePlate,
    amount: model.amount,
    status: _mapModelStatusToEntityStatus(model.status),
  );
}

List<domain_entity.BookingEntity> _mapBookingModelListToEntityList(List<booking_model.Booking> models) {
  return models.map(_mapBookingModelToEntity).toList();
}

domain_entity.BookingStatus _mapModelStatusToEntityStatus(booking_model.BookingStatus modelStatus) {
  switch (modelStatus) {
    case booking_model.BookingStatus.pending:
      return domain_entity.BookingStatus.pending;
    case booking_model.BookingStatus.confirmed:
    case booking_model.BookingStatus.active:
      return domain_entity.BookingStatus.confirmed;
    case booking_model.BookingStatus.completed:
      return domain_entity.BookingStatus.completed;
    case booking_model.BookingStatus.cancelled:
      return domain_entity.BookingStatus.cancelled;
    default:
      print("Warning: Unhandled booking_model.BookingStatus: $modelStatus. Defaulting to domain_entity.BookingStatus.pending.");
      return domain_entity.BookingStatus.pending;
  }
}

booking_model.BookingStatus _mapEntityStatusToModelStatus(domain_entity.BookingStatus entityStatus) {
  switch (entityStatus) {
    case domain_entity.BookingStatus.pending:
      return booking_model.BookingStatus.pending;
    case domain_entity.BookingStatus.confirmed:
      return booking_model.BookingStatus.confirmed;
    case domain_entity.BookingStatus.completed:
      return booking_model.BookingStatus.completed;
    case domain_entity.BookingStatus.cancelled:
      return booking_model.BookingStatus.cancelled;
    default:
      print("Warning: Unhandled domain_entity.BookingStatus: $entityStatus. Defaulting to booking_model.BookingStatus.pending.");
      return booking_model.BookingStatus.pending;
  }
}

class BookingRepositoryImpl implements BookingRepository {
  final BookingService bookingService;

  BookingRepositoryImpl({required this.bookingService});

  @override
  Future<Either<Failure, domain_entity.BookingEntity>> createBooking({
    required String parkingSpotId,
    required String parkingSpotName,
    required DateTime startTime,
    required DateTime endTime,
    required String vehicleType,
    required String vehiclePlate,
    required double amount,
  }) async {
    try {
      final bookingDataForService = booking_model.Booking(
        id: '', // Dummy ID, will be overridden by service
        parkingSpotId: parkingSpotId,
        parkingSpotName: parkingSpotName,
        startTime: startTime,
        endTime: endTime,
        vehiclePlate: vehiclePlate,
        vehicleType: vehicleType,
        amount: amount,
        status: booking_model.BookingStatus.pending,
        createdAt: DateTime(0), // Dummy date, will be overridden by service
      );

      final resultingBookingModel = await bookingService.createBooking(bookingDataForService);
      return Right(_mapBookingModelToEntity(resultingBookingModel));
    } catch (e) {
      return Left(ServerFailure(message: "Failed to create booking: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, List<domain_entity.BookingEntity>>> getUserBookings() async {
    try {
      final bookingModels = await bookingService.getUserBookings();
      return Right(_mapBookingModelListToEntityList(bookingModels));
    } catch (e) {
      return Left(ServerFailure(message: "Failed to get user bookings: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, domain_entity.BookingEntity>> getBookingById(String id) async {
    try {
      final bookingModel = bookingService.getBookingById(id);
      if (bookingModel != null) {
        return Right(_mapBookingModelToEntity(bookingModel));
      } else {
        return Left(NotFoundFailure(message: 'Booking not found with id: $id'));
      }
    } catch (e) {
      return Left(ServerFailure(message: "Failed to get booking by id: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, domain_entity.BookingEntity>> updateBookingStatus(String id, domain_entity.BookingStatus status) async {
    try {
      final modelStatus = _mapEntityStatusToModelStatus(status);
      final bookingModel = await bookingService.updateBookingStatus(id, modelStatus);
      return Right(_mapBookingModelToEntity(bookingModel));
    } catch (e) {
      return Left(ServerFailure(message: "Failed to update booking status: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, List<domain_entity.BookingEntity>>> getActiveBookings() async {
    try {
      final bookingModels = bookingService.getActiveBookings();
      return Right(_mapBookingModelListToEntityList(bookingModels));
    } catch (e) {
      return Left(ServerFailure(message: "Failed to get active bookings: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, List<domain_entity.BookingEntity>>> getUpcomingBookings() async {
    try {
      final bookingModels = bookingService.getUpcomingBookings();
      return Right(_mapBookingModelListToEntityList(bookingModels));
    } catch (e) {
      return Left(ServerFailure(message: "Failed to get upcoming bookings: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, List<domain_entity.BookingEntity>>> getPastBookings() async {
    try {
      final bookingModels = bookingService.getPastBookings();
      return Right(_mapBookingModelListToEntityList(bookingModels));
    } catch (e) {
      return Left(ServerFailure(message: "Failed to get past bookings: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking(String id) async {
    try {
      await bookingService.cancelBooking(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: "Failed to cancel booking: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, bool>> processPayment(
      String bookingId,
      String paymentMethod,
      {Map<String, dynamic>? paymentDetails}
      ) async {
    try {
      await bookingService.completePayment(bookingId);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: "Payment processing failed: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, double>> calculateBookingAmount(
      String spotId,
      DateTime startTime,
      DateTime endTime,
      ) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return Left(ServerFailure(message: 'calculateBookingAmount not implemented in service'));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBookingStatistics(
      DateTime startDate,
      DateTime endDate,
      ) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return Left(ServerFailure(message: 'getBookingStatistics not implemented in service'));
  }
}
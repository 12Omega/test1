// lib/presentation/bloc/booking/booking_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_parking_app/domain/entities/booking_entity.dart'; // Needed for BookingStatus
import 'package:smart_parking_app/domain/repositories/booking_repository.dart';
import 'package:smart_parking_app/presentation/bloc/booking/booking_event.dart';
import 'package:smart_parking_app/presentation/bloc/booking/booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository bookingRepository;

  BookingBloc({required this.bookingRepository}) : super(BookingInitial()) {
    on<CreateBookingEvent>(_onCreateBooking);
    on<GetUserBookingsEvent>(_onGetUserBookings);
    on<GetBookingByIdEvent>(_onGetBookingById);
    on<UpdateBookingStatusEvent>(_onUpdateBookingStatus);
    on<GetActiveBookingsEvent>(_onGetActiveBookings);
    on<GetUpcomingBookingsEvent>(_onGetUpcomingBookings);
    on<GetPastBookingsEvent>(_onGetPastBookings);
  }

  Future<void> _onCreateBooking(
      CreateBookingEvent event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingLoading());

    final result = await bookingRepository.createBooking(
      parkingSpotId: event.parkingSpotId,
      parkingSpotName: event.parkingSpotName,
      startTime: event.startTime,
      endTime: event.endTime,
      vehicleType: event.vehicleType,
      vehiclePlate: event.vehiclePlate,
      amount: event.amount,
    );

    result.fold(
          (failure) => emit(BookingError(message: failure.message)),
          (booking) => emit(BookingCreationSuccess(booking: booking)),
    );
  }

  Future<void> _onGetUserBookings(
      GetUserBookingsEvent event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingLoading());

    final result = await bookingRepository.getUserBookings();

    result.fold(
          (failure) => emit(BookingError(message: failure.message)),
          (bookings) {
        if (bookings.isEmpty) {
          emit(const NoBookingsFound(message: 'You have no bookings yet'));
        } else {
          emit(UserBookingsLoaded(bookings: bookings));
        }
      },
    );
  }

  Future<void> _onGetBookingById(
      GetBookingByIdEvent event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingLoading());

    final result = await bookingRepository.getBookingById(event.id);

    result.fold(
          (failure) => emit(BookingError(message: failure.message)),
          (booking) => emit(BookingDetailsLoaded(booking: booking)),
    );
  }

  Future<void> _onUpdateBookingStatus(
      UpdateBookingStatusEvent event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingLoading());

    final result = await bookingRepository.updateBookingStatus(
      event.id,
      event.status,
    );

    result.fold(
          (failure) => emit(BookingError(message: failure.message)),
          (booking) => emit(BookingStatusUpdateSuccess(
        booking: booking,
        message: 'Booking status updated to ${_getStatusMessage(event.status)}',
      )),
    );
  }

  Future<void> _onGetActiveBookings(
      GetActiveBookingsEvent event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingLoading());

    final result = await bookingRepository.getActiveBookings();

    result.fold(
          (failure) => emit(BookingError(message: failure.message)),
          (bookings) {
        if (bookings.isEmpty) {
          emit(const NoBookingsFound(message: 'You have no active bookings'));
        } else {
          emit(ActiveBookingsLoaded(bookings: bookings));
        }
      },
    );
  }

  Future<void> _onGetUpcomingBookings(
      GetUpcomingBookingsEvent event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingLoading());

    final result = await bookingRepository.getUpcomingBookings();

    result.fold(
          (failure) => emit(BookingError(message: failure.message)),
          (bookings) {
        if (bookings.isEmpty) {
          emit(const NoBookingsFound(message: 'You have no upcoming bookings'));
        } else {
          emit(UpcomingBookingsLoaded(bookings: bookings));
        }
      },
    );
  }

  Future<void> _onGetPastBookings(
      GetPastBookingsEvent event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingLoading());

    final result = await bookingRepository.getPastBookings();

    result.fold(
          (failure) => emit(BookingError(message: failure.message)),
          (bookings) {
        if (bookings.isEmpty) {
          emit(const NoBookingsFound(message: 'You have no past bookings'));
        } else {
          emit(PastBookingsLoaded(bookings: bookings));
        }
      },
    );
  }

  String _getStatusMessage(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending: // Added pending from BookingEntity's enum
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
    // Removed 'active' as it's not in BookingEntity's BookingStatus enum
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      default: // This will catch any other values if they exist, or be 'Unknown'
        return status.toString().split('.').last; // Provides a default string like "pending"
    }
  }
}
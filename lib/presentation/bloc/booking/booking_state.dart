// lib/presentation/bloc/booking/booking_state.dart
import 'package:equatable/equatable.dart';
import 'package:smart_parking_app/domain/entities/booking_entity.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingCreationSuccess extends BookingState {
  final BookingEntity booking;

  const BookingCreationSuccess({required this.booking});

  @override
  List<Object?> get props => [booking];
}

class BookingDetailsLoaded extends BookingState {
  final BookingEntity booking;

  const BookingDetailsLoaded({required this.booking});

  @override
  List<Object?> get props => [booking];
}

class UserBookingsLoaded extends BookingState {
  final List<BookingEntity> bookings;

  const UserBookingsLoaded({required this.bookings});

  @override
  List<Object?> get props => [bookings];
}

class ActiveBookingsLoaded extends BookingState {
  final List<BookingEntity> bookings;

  const ActiveBookingsLoaded({required this.bookings});

  @override
  List<Object?> get props => [bookings];
}

class UpcomingBookingsLoaded extends BookingState {
  final List<BookingEntity> bookings;

  const UpcomingBookingsLoaded({required this.bookings});

  @override
  List<Object?> get props => [bookings];
}

class PastBookingsLoaded extends BookingState {
  final List<BookingEntity> bookings;

  const PastBookingsLoaded({required this.bookings});

  @override
  List<Object?> get props => [bookings];
}

class BookingStatusUpdateSuccess extends BookingState {
  final BookingEntity booking;
  final String message;

  const BookingStatusUpdateSuccess({
    required this.booking,
    required this.message,
  });

  @override
  List<Object?> get props => [booking, message];
}

class BookingError extends BookingState {
  final String message;

  const BookingError({required this.message});

  @override
  List<Object?> get props => [message];
}

class NoBookingsFound extends BookingState {
  final String message;

  const NoBookingsFound({required this.message});

  @override
  List<Object?> get props => [message];
}
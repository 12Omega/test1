// lib/presentation/bloc/booking/booking_event.dart
import 'package:equatable/equatable.dart';
import 'package:smart_parking_app/domain/entities/booking_entity.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class CreateBookingEvent extends BookingEvent {
  final String parkingSpotId;
  final String parkingSpotName;
  final DateTime startTime;
  final DateTime endTime;
  final String vehicleType;
  final String vehiclePlate;
  final double amount;

  const CreateBookingEvent({
    required this.parkingSpotId,
    required this.parkingSpotName,
    required this.startTime,
    required this.endTime,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.amount,
  });

  @override
  List<Object?> get props => [
    parkingSpotId, 
    parkingSpotName,
    startTime, 
    endTime, 
    vehicleType, 
    vehiclePlate, 
    amount,
  ];
}

class GetUserBookingsEvent extends BookingEvent {}

class GetBookingByIdEvent extends BookingEvent {
  final String id;

  const GetBookingByIdEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class UpdateBookingStatusEvent extends BookingEvent {
  final String id;
  final BookingStatus status;

  const UpdateBookingStatusEvent({
    required this.id,
    required this.status,
  });

  @override
  List<Object?> get props => [id, status];
}

class GetActiveBookingsEvent extends BookingEvent {}

class GetUpcomingBookingsEvent extends BookingEvent {}

class GetPastBookingsEvent extends BookingEvent {}
// lib/models/booking.dart
import 'dart:convert';
import 'package:smart_parking_app/domain/entities/booking_entity.dart' as entities;

enum BookingStatus {
  pending,
  confirmed,
  active,
  completed,
  cancelled,
}

class Booking {
  final String id;
  final String parkingSpotId;
  final String parkingSpotName;
  final DateTime startTime;
  final DateTime endTime;
  final String vehicleType;
  final String vehiclePlate;
  final double amount;
  final BookingStatus status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.parkingSpotId,
    required this.parkingSpotName,
    required this.startTime,
    required this.endTime,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parkingSpotId': parkingSpotId,
      'parkingSpotName': parkingSpotName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'vehicleType': vehicleType,
      'vehiclePlate': vehiclePlate,
      'amount': amount,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] ?? map['_id']?.toString() ?? '',
      parkingSpotId: map['parkingSpotId'] ?? '',
      parkingSpotName: map['parkingSpotName'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      vehicleType: map['vehicleType'] ?? '',
      vehiclePlate: map['vehiclePlate'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      status: _parseStatus(map['status']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  static BookingStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'active':
        return BookingStatus.active;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  String toJson() => json.encode(toMap());

  factory Booking.fromJson(String source) => Booking.fromMap(json.decode(source));

  Booking copyWith({
    String? id,
    String? parkingSpotId,
    String? parkingSpotName,
    DateTime? startTime,
    DateTime? endTime,
    String? vehicleType,
    String? vehiclePlate,
    double? amount,
    BookingStatus? status,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      parkingSpotId: parkingSpotId ?? this.parkingSpotId,
      parkingSpotName: parkingSpotName ?? this.parkingSpotName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      vehicleType: vehicleType ?? this.vehicleType,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Booking(id: $id, parkingSpotId: $parkingSpotId, parkingSpotName: $parkingSpotName, startTime: $startTime, endTime: $endTime, vehicleType: $vehicleType, vehiclePlate: $vehiclePlate, amount: $amount, status: $status, createdAt: $createdAt)';
  }

  // Calculate duration in hours
  double get durationInHours {
    return endTime.difference(startTime).inMinutes / 60;
  }

  // Check if booking is currently active
  bool get isActive {
    final now = DateTime.now();
    return status == BookingStatus.confirmed &&
        now.isAfter(startTime) &&
        now.isBefore(endTime);
  }

  // Check if booking is upcoming (confirmed but not yet started)
  bool get isUpcoming {
    final now = DateTime.now();
    return status == BookingStatus.confirmed && now.isBefore(startTime);
  }

  // Check if booking is past (ended)
  bool get isPast {
    final now = DateTime.now();
    return status == BookingStatus.completed ||
        (status == BookingStatus.confirmed && now.isAfter(endTime));
  }

  entities.BookingEntity toEntity() {
    return entities.BookingEntity(
      id: id,
      parkingSpotId: parkingSpotId,
      parkingSpotName: parkingSpotName,
      startTime: startTime,
      endTime: endTime,
      vehicleType: vehicleType,
      vehiclePlate: vehiclePlate,
      amount: amount,
      status: _mapModelStatusToEntityStatus(status),
      // createdAt is not in BookingEntity, so it's omitted
    );
  }
}

// Helper function to map model status to entity status
// This should ideally be part of the Booking model or a dedicated mapper class
entities.BookingStatus _mapModelStatusToEntityStatus(BookingStatus modelStatus) {
  switch (modelStatus) {
    case BookingStatus.pending:
      return entities.BookingStatus.pending;
    case BookingStatus.confirmed:
    case BookingStatus.active: // Map model's 'active' to entity's 'confirmed'
      return entities.BookingStatus.confirmed;
    case BookingStatus.completed:
      return entities.BookingStatus.completed;
    case BookingStatus.cancelled:
      return entities.BookingStatus.cancelled;
    default:
    // This case should ideally not be reached if all model statuses are handled.
    // Throw an error or return a default entity status.
    // For safety, let's default to pending or throw.
    // Depending on strictness, you might prefer:
    // throw ArgumentError('Unknown BookingStatus from model: $modelStatus');
      return entities.BookingStatus.pending;
  }
}

// Need to import: import 'package:smart_parking_app/domain/entities/booking_entity.dart' as entities;
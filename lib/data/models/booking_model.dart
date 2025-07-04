// lib/data/models/booking_model.dart
import 'dart:convert';
import 'package:smart_parking_app/domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  final DateTime createdAt;

  const BookingModel({
    required String id,
    required String parkingSpotId,
    required String parkingSpotName,
    required DateTime startTime,
    required DateTime endTime,
    required String vehicleType,
    required String vehiclePlate,
    required double amount,
    required BookingStatus status,
    required this.createdAt,
  }) : super(
    id: id,
    parkingSpotId: parkingSpotId,
    parkingSpotName: parkingSpotName,
    startTime: startTime,
    endTime: endTime,
    vehicleType: vehicleType,
    vehiclePlate: vehiclePlate,
    amount: amount,
    status: status,
  );

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

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
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
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  String toJson() => json.encode(toMap());

  factory BookingModel.fromJson(String source) => 
      BookingModel.fromMap(json.decode(source));

  BookingModel copyWith({
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
    return BookingModel(
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
  
  // Additional utility methods
  
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
}
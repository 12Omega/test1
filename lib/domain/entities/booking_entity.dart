// lib/domain/entities/booking_entity.dart

enum BookingStatus { pending, confirmed, completed, cancelled }

class BookingEntity {
  final String id;
  final String parkingSpotId;
  final String parkingSpotName;
  final DateTime startTime;
  final DateTime endTime;
  final String vehicleType;
  final String vehiclePlate;
  final double amount;
  final BookingStatus status;

  const BookingEntity({
    required this.id,
    required this.parkingSpotId,
    required this.parkingSpotName,
    required this.startTime,
    required this.endTime,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.amount,
    required this.status,
  });

  // Get booking duration in hours
  double get durationInHours {
    return endTime.difference(startTime).inMinutes / 60;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is BookingEntity &&
      other.id == id &&
      other.parkingSpotId == parkingSpotId &&
      other.startTime == startTime &&
      other.endTime == endTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      parkingSpotId.hashCode ^
      startTime.hashCode ^
      endTime.hashCode;
  }
  
  @override
  String toString() {
    return 'BookingEntity(id: $id, parkingSpotId: $parkingSpotId, parkingSpotName: $parkingSpotName, startTime: $startTime, endTime: $endTime, vehicleType: $vehicleType, vehiclePlate: $vehiclePlate, amount: $amount, status: $status)';
  }
}
// lib/domain/entities/parking_spot_entity.dart

class ParkingSpotEntity {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int availableSpots;
  final int totalSpots;
  final double hourlyRate;
  final bool isOpen;
  final List<String> features;
  final String address;
  final String imageUrl;
  final double? distance;
  final bool is24Hours;
  final String? contactNumber;
  
  const ParkingSpotEntity({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.availableSpots,
    required this.totalSpots,
    required this.hourlyRate,
    required this.isOpen,
    required this.features,
    required this.address,
    required this.imageUrl,
    this.distance,
    this.is24Hours = false,
    this.contactNumber,
  });
  
  bool get hasAvailability => availableSpots > 0;
  
  double get occupancyRate => (totalSpots - availableSpots) / totalSpots;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ParkingSpotEntity &&
      other.id == id &&
      other.name == name &&
      other.latitude == latitude &&
      other.longitude == longitude;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      latitude.hashCode ^
      longitude.hashCode;
  }
  
  @override
  String toString() {
    return 'ParkingSpotEntity(id: $id, name: $name, latitude: $latitude, longitude: $longitude, availableSpots: $availableSpots, totalSpots: $totalSpots, hourlyRate: $hourlyRate, isOpen: $isOpen)';
  }
}
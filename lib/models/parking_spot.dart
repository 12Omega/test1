// lib/models/parking_spot.dart
import 'dart:convert';

class ParkingSpot {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int capacity;
  final int availableSpots;
  final String rate; // e.g. "Rs. 60/hr"
  final String openHours; // e.g. "24 hours" or "6:00 AM - 10:00 PM"
  final double rating;
  final List<String> features; // e.g. ["CCTV", "Covered", "Security", "EV Charging"]
  final DateTime updatedAt;

  ParkingSpot({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.availableSpots,
    required this.rate,
    required this.openHours,
    required this.rating,
    required this.features,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'capacity': capacity,
      'availableSpots': availableSpots,
      'rate': rate,
      'openHours': openHours,
      'rating': rating,
      'features': features,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ParkingSpot.fromMap(Map<String, dynamic> map) {
    return ParkingSpot(
      id: map['id'] ?? map['_id']?.toString() ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      capacity: map['capacity']?.toInt() ?? 0,
      availableSpots: map['availableSpots']?.toInt() ?? 0,
      rate: map['rate'] ?? 'Rs. 0/hr',
      openHours: map['openHours'] ?? '24 hours',
      rating: map['rating']?.toDouble() ?? 0.0,
      features: List<String>.from(map['features'] ?? []),
      updatedAt: map['updatedAt'] != null 
        ? DateTime.parse(map['updatedAt'])
        : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ParkingSpot.fromJson(String source) => ParkingSpot.fromMap(json.decode(source));

  ParkingSpot copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? capacity,
    int? availableSpots,
    String? rate,
    String? openHours,
    double? rating,
    List<String>? features,
    DateTime? updatedAt,
  }) {
    return ParkingSpot(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      capacity: capacity ?? this.capacity,
      availableSpots: availableSpots ?? this.availableSpots,
      rate: rate ?? this.rate,
      openHours: openHours ?? this.openHours,
      rating: rating ?? this.rating,
      features: features ?? this.features,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ParkingSpot(id: $id, name: $name, address: $address, latitude: $latitude, longitude: $longitude, capacity: $capacity, availableSpots: $availableSpots, rate: $rate, openHours: $openHours, rating: $rating, features: $features, updatedAt: $updatedAt)';
  }
  
  // Calculate distance from current position
  double distanceFrom(double lat, double lng) {
    // Simple Euclidean distance for demo purposes
    // In a real app, use the Haversine formula or a Maps API
    return _calculateDistance(latitude, longitude, lat, lng);
  }
  
  // Helper method to calculate distance using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // in kilometers
    
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = 
      (dLat / 2).sin() * (dLat / 2).sin() +
      (dLon / 2).sin() * (dLon / 2).sin() * 
      _toRadians(lat1).cos() * _toRadians(lat2).cos();
      
    double c = 2 * (a.sqrt()).asin();
    return earthRadius * c; // Distance in km
  }
  
  double _toRadians(double degree) {
    return degree * (3.141592653589793 / 180);
  }
}
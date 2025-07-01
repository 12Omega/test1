// lib/data/models/parking_spot_model.dart
import 'dart:convert';
import 'package:smart_parking_app/domain/entities/parking_spot_entity.dart';

class ParkingSpotModel extends ParkingSpotEntity {
  final DateTime updatedAt;

  const ParkingSpotModel({
    required String id,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required int capacity,
    required int availableSpots,
    required String rate,
    required String openHours,
    required double rating,
    required List<String> features,
    required this.updatedAt,
  }) : super(
    id: id,
    name: name,
    address: address,
    latitude: latitude,
    longitude: longitude,
    capacity: capacity,
    availableSpots: availableSpots,
    rate: rate,
    openHours: openHours,
    rating: rating,
    features: features,
  );

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

  factory ParkingSpotModel.fromMap(Map<String, dynamic> map) {
    return ParkingSpotModel(
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

  factory ParkingSpotModel.fromJson(String source) => 
      ParkingSpotModel.fromMap(json.decode(source));

  ParkingSpotModel copyWith({
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
    return ParkingSpotModel(
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
}
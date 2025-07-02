// lib/data/models/parking_spot_model.dart
import 'dart:convert';
import 'package:smart_parking_app/domain/entities/parking_spot_entity.dart';

class ParkingSpotModel extends ParkingSpotEntity {
  final DateTime updatedAt;
  final String openHoursString;
  final double ratingScore;

  const ParkingSpotModel({
    required String id,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required int totalSpots,
    required int availableSpots,
    required double hourlyRate,
    required bool isOpen,
    required String imageUrl,
    required List<String> features,
    required this.updatedAt,
    required this.openHoursString, // Corrected: Added 'this.'
    required this.ratingScore,     // Corrected: Added 'this.'
  }) : super(
    id: id,
    name: name,
    address: address,
    latitude: latitude,
    longitude: longitude,
    totalSpots: totalSpots,
    availableSpots: availableSpots,
    hourlyRate: hourlyRate,
    isOpen: isOpen,
    imageUrl: imageUrl,
    features: features,
  );

  Map<String, dynamic> toMap() {
    return {
      'id': super.id,
      'name': super.name,
      'address': super.address,
      'latitude': super.latitude,
      'longitude': super.longitude,
      'totalSpots': super.totalSpots,
      'availableSpots': super.availableSpots,
      'hourlyRate': super.hourlyRate,
      'isOpen': super.isOpen,
      'imageUrl': super.imageUrl,
      'features': super.features,
      'updatedAt': updatedAt.toIso8601String(),
      'openHours': openHoursString,
      'rating': ratingScore,
    };
  }

  static double _parseRate(String rateString) {
    try {
      var numericPart = rateString.replaceAll(RegExp(r'[^0-9.]'), '');
      if (numericPart.isEmpty) return 0.0; // Handle empty string after replace
      return double.parse(numericPart);
    } catch (e) {
      return 0.0;
    }
  }

  factory ParkingSpotModel.fromMap(Map<String, dynamic> map) {
    return ParkingSpotModel(
      id: map['id'] ?? map['_id']?.toString() ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      totalSpots: map['totalSpots']?.toInt() ?? map['capacity']?.toInt() ?? 0,
      availableSpots: map['availableSpots']?.toInt() ?? 0,
      hourlyRate: _parseRate(map['hourlyRate']?.toString() ?? map['rate']?.toString() ?? '0'),
      isOpen: map['isOpen'] ?? false,
      imageUrl: map['imageUrl'] ?? '',
      features: List<String>.from(map['features'] ?? []),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      openHoursString: map['openHours'] ?? '24 hours',
      ratingScore: map['rating']?.toDouble() ?? 0.0,
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
    int? totalSpots,
    int? availableSpots,
    double? hourlyRate,
    bool? isOpen,
    String? imageUrl,
    List<String>? features,
    DateTime? updatedAt,
    String? openHoursString,
    double? ratingScore,
  }) {
    return ParkingSpotModel(
      id: id ?? super.id,
      name: name ?? super.name,
      address: address ?? super.address,
      latitude: latitude ?? super.latitude,
      longitude: longitude ?? super.longitude,
      totalSpots: totalSpots ?? super.totalSpots,
      availableSpots: availableSpots ?? super.availableSpots,
      hourlyRate: hourlyRate ?? super.hourlyRate,
      isOpen: isOpen ?? super.isOpen,
      imageUrl: imageUrl ?? super.imageUrl,
      features: features ?? super.features,
      updatedAt: updatedAt ?? this.updatedAt,
      openHoursString: openHoursString ?? this.openHoursString,
      ratingScore: ratingScore ?? this.ratingScore,
    );
  }
}
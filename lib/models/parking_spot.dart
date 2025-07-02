// lib/models/parking_spot.dart
import 'dart:convert';
import 'dart:math' as math; // Aliased import
import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:smart_parking_app/domain/entities/parking_spot_entity.dart';


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
  final double ratePerHourNumeric; // Added for easier sorting/filtering
  final String? imageUrl; // Added for entity mapping
  final String? contactNumber; // Added for entity mapping

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
    this.imageUrl,
    this.contactNumber,
  }) : ratePerHourNumeric = _parseRate(rate);

  static double _parseRate(String rateStr) {
    try {
      return double.parse(rateStr.replaceAll(RegExp(r'[^0-9.]'), ''));
    } catch (e) {
      return 0.0; // Default if parsing fails
    }
  }

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
      'ratePerHourNumeric': ratePerHourNumeric,
      'imageUrl': imageUrl,
      'contactNumber': contactNumber,
    };
  }

  factory ParkingSpot.fromMap(Map<String, dynamic> map) {
    String rateString = map['rate'] ?? 'Rs. 0/hr';
    return ParkingSpot(
      id: map['id'] ?? map['_id']?.toString() ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      capacity: map['capacity']?.toInt() ?? 0,
      availableSpots: map['availableSpots']?.toInt() ?? 0,
      rate: rateString,
      // ratePerHourNumeric is handled by constructor
      openHours: map['openHours'] ?? '24 hours',
      rating: map['rating']?.toDouble() ?? 0.0,
      features: List<String>.from(map['features'] ?? []),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      imageUrl: map['imageUrl'] as String?,
      contactNumber: map['contactNumber'] as String?,
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
    String? imageUrl, // Added
    String? contactNumber, // Added
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
      imageUrl: imageUrl ?? this.imageUrl,
      contactNumber: contactNumber ?? this.contactNumber,
    );
  }

  @override
  String toString() {
    return 'ParkingSpot(id: $id, name: $name, address: $address, latitude: $latitude, longitude: $longitude, capacity: $capacity, availableSpots: $availableSpots, rate: $rate, openHours: $openHours, rating: $rating, features: $features, updatedAt: $updatedAt, ratePerHourNumeric: $ratePerHourNumeric, imageUrl: $imageUrl, contactNumber: $contactNumber)';
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

    double val1 = math.sin(dLat / 2) * math.sin(dLat / 2);
    double val2 = math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    double a = val1 + val2;

    double c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c; // Distance in km
  }

  double _toRadians(double degree) {
    return degree * (math.pi / 180); // Use math.pi
  }

  // Mapper to ParkingSpotEntity
  ParkingSpotEntity toEntity() {
    return ParkingSpotEntity(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      availableSpots: availableSpots,
      totalSpots: capacity, // Map capacity to totalSpots
      hourlyRate: ratePerHourNumeric, // Use the numeric rate
      isOpen: openHours.toLowerCase() == '24 hours' || _isCurrentlyOpen(openHours), // Basic logic for isOpen
      features: features,
      address: address,
      imageUrl: imageUrl ?? 'https://picsum.photos/seed/$id/400/300', // Default if null
      is24Hours: openHours.toLowerCase() == '24 hours',
      contactNumber: contactNumber,
      // distance can be calculated separately if needed by use case
    );
  }

  // Helper to check if currently open based on string like "6:00 AM - 10:00 PM"
  // This is a simplified example and might need robust parsing for real-world scenarios
  bool _isCurrentlyOpen(String openHoursString) {
    if (openHoursString.toLowerCase() == '24 hours') return true;
    try {
      final parts = openHoursString.split(' - ');
      if (parts.length != 2) return false; // Cannot parse

      final now = TimeOfDay.now();

      final startTimeStr = parts[0]; // e.g., "6:00 AM"
      final endTimeStr = parts[1];   // e.g., "10:00 PM"

      TimeOfDay parseTime(String timeStr) {
        final timeParts = timeStr.split(' ')[0].split(':'); // "6:00"
        final period = timeStr.split(' ')[1]; // "AM" or "PM"
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);

        if (period.toUpperCase() == 'PM' && hour != 12) hour += 12;
        if (period.toUpperCase() == 'AM' && hour == 12) hour = 0; // Midnight case
        return TimeOfDay(hour: hour, minute: minute);
      }

      final startTime = parseTime(startTimeStr);
      final endTime = parseTime(endTimeStr);

      final currentTimeInMinutes = now.hour * 60 + now.minute;
      final startTimeInMinutes = startTime.hour * 60 + startTime.minute;
      final endTimeInMinutes = endTime.hour * 60 + endTime.minute;

      if (startTimeInMinutes <= endTimeInMinutes) { // Opens and closes on the same day
        return currentTimeInMinutes >= startTimeInMinutes && currentTimeInMinutes <= endTimeInMinutes;
      } else { // Opens one day and closes the next (e.g. 10 PM - 6 AM)
        return currentTimeInMinutes >= startTimeInMinutes || currentTimeInMinutes <= endTimeInMinutes;
      }
    } catch (e) {
      return false; // Error parsing, assume closed
    }
  }
}
// Need to import:
// import 'package:flutter/material.dart'; // For TimeOfDay
// import 'package:smart_parking_app/domain/entities/parking_spot_entity.dart';
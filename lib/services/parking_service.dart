// lib/services/parking_service.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:smart_parking_app/models/parking_spot.dart';

class ParkingService extends ChangeNotifier {
  List<ParkingSpot> _parkingSpots = [];
  
  // Kathmandu boundaries for random generation
  static const double _kathmandu_min_lat = 27.6698;
  static const double _kathmandu_max_lat = 27.7300;
  static const double _kathmandu_min_lng = 85.2885;
  static const double _kathmandu_max_lng = 85.3700;
  
  // Key locations in Kathmandu (for more realistic placements)
  static const List<Map<String, dynamic>> _kathmandu_locations = [
    {'name': 'Thamel', 'lat': 27.7154, 'lng': 85.3123, 'address': 'Thamel, Kathmandu'},
    {'name': 'Durbar Marg', 'lat': 27.7105, 'lng': 85.3172, 'address': 'Durbar Marg, Kathmandu'},
    {'name': 'New Road', 'lat': 27.7041, 'lng': 85.3104, 'address': 'New Road, Kathmandu'},
    {'name': 'Patan Durbar Square', 'lat': 27.6737, 'lng': 85.3257, 'address': 'Patan Durbar Square, Lalitpur'},
    {'name': 'Bouddhanath Stupa', 'lat': 27.7215, 'lng': 85.3620, 'address': 'Bouddhanath, Kathmandu'},
    {'name': 'Swayambhunath', 'lat': 27.7149, 'lng': 85.2900, 'address': 'Swayambhunath, Kathmandu'},
    {'name': 'Tripureshwor', 'lat': 27.6960, 'lng': 85.3110, 'address': 'Tripureshwor, Kathmandu'},
    {'name': 'New Baneshwor', 'lat': 27.6885, 'lng': 85.3400, 'address': 'New Baneshwor, Kathmandu'},
    {'name': 'Chabahil', 'lat': 27.7137, 'lng': 85.3450, 'address': 'Chabahil, Kathmandu'},
    {'name': 'Balaju', 'lat': 27.7350, 'lng': 85.3030, 'address': 'Balaju, Kathmandu'},
    {'name': 'Kalimati', 'lat': 27.6994, 'lng': 85.2999, 'address': 'Kalimati, Kathmandu'},
    {'name': 'Koteshwor', 'lat': 27.6780, 'lng': 85.3470, 'address': 'Koteshwor, Kathmandu'},
    {'name': 'Kalanki', 'lat': 27.6930, 'lng': 85.2820, 'address': 'Kalanki, Kathmandu'},
    {'name': 'Gongabu', 'lat': 27.7360, 'lng': 85.3160, 'address': 'Gongabu, Kathmandu'},
    {'name': 'Lainchaur', 'lat': 27.7178, 'lng': 85.3141, 'address': 'Lainchaur, Kathmandu'}
  ];
  
  // Parking names to use for random generation
  static const List<String> _parkingNames = [
    'Central Parking',
    'City Parking Zone',
    'Royal Parking',
    'Everest Parking',
    'Himalayan Parking',
    'Buddha Parking',
    'Sagarmatha Parking',
    'Pashupatinath Parking',
    'Mountain View Parking',
    'Kathmandu Plaza Parking',
    'Durbar Parking',
    'Thamel Parking Complex',
    'Patan Parking Area',
    'Nepal Parking Services',
    'Bouddha Parking Zone',
    'City Centre Parking',
    'Newroad Parking',
    'Lalitpur Parking Zone',
    'Bhaktapur Parking',
    'Metro Parking'
  ];

  // Parking features
  static const List<String> _parkingFeatures = [
    'CCTV',
    'Security Guard',
    'Covered Parking',
    'Open 24/7',
    'Motorcycle Parking',
    'Car Parking',
    'EV Charging',
    'Valet Service',
    'Washing Service',
    'Reserved Spaces',
    'Wheel Clamping',
    'Mobile Payment',
    'Monthly Pass',
    'Lighting',
    'Restrooms',
    'WiFi'
  ];

  // Constructor that initializes with random parking spots
  ParkingService() {
    _generateRandomParkingSpots();
  }

  // Get all parking spots
  List<ParkingSpot> get parkingSpots => _parkingSpots;

  // Generate random parking spots
  void _generateRandomParkingSpots() {
    final random = Random();
    List<ParkingSpot> spots = [];
    
    // Generate parking spots near key locations
    for (var location in _kathmandu_locations) {
      // Add 1-3 parking spots near each key location
      int numSpots = random.nextInt(3) + 1;
      
      for (int i = 0; i < numSpots; i++) {
        // Create a slight offset from the exact location coordinates
        double latOffset = (random.nextDouble() - 0.5) * 0.01;  // ~500m radius
        double lngOffset = (random.nextDouble() - 0.5) * 0.01;
        
        double lat = location['lat'] + latOffset;
        double lng = location['lng'] + lngOffset;
        
        // Keep coordinates within Kathmandu boundaries
        lat = lat.clamp(_kathmandu_min_lat, _kathmandu_max_lat);
        lng = lng.clamp(_kathmandu_min_lng, _kathmandu_max_lng);
        
        // Generate other random parking data
        String id = 'parking_${spots.length + 1}';
        String name = _parkingNames[random.nextInt(_parkingNames.length)];
        if (spots.any((spot) => spot.name == name)) {
          name = '$name ${spots.length + 1}';  // Make name unique
        }
        
        // Generate address based on location
        String address = '${random.nextInt(100) + 1}, ${location['address']}';
        
        // Random capacity between 10 and 100
        int capacity = (random.nextInt(10) + 1) * 10;
        
        // Random available spots (some might be full)
        int availableSpots = random.nextDouble() < 0.1 ? 0 : random.nextInt(capacity + 1);
        
        // Random rate between Rs. 20 and Rs. 100 per hour
        int rate = (random.nextInt(9) + 2) * 10;  // 20, 30, 40, ..., 100
        String rateStr = 'Rs. $rate/hr';
        
        // Random open hours (most open 24/7)
        String openHours = random.nextDouble() < 0.7 ? '24 hours' : '6:00 AM - 10:00 PM';
        
        // Random rating between 3.0 and 5.0
        double rating = 3.0 + random.nextDouble() * 2.0;
        rating = double.parse(rating.toStringAsFixed(1));  // Round to 1 decimal place
        
        // Random features (3-6 features per parking)
        int featureCount = random.nextInt(4) + 3;
        List<String> shuffledFeatures = List<String>.from(_parkingFeatures)..shuffle();
        List<String> features = shuffledFeatures.take(featureCount).toList();
        
        spots.add(
          ParkingSpot(
            id: id,
            name: name,
            address: address,
            latitude: lat,
            longitude: lng,
            capacity: capacity,
            availableSpots: availableSpots,
            rate: rateStr,
            openHours: openHours,
            rating: rating,
            features: features,
            updatedAt: DateTime.now(),
          ),
        );
      }
    }
    
    // Add a few completely random spots across Kathmandu
    int additionalSpots = random.nextInt(10) + 5;  // 5-14 additional spots
    
    for (int i = 0; i < additionalSpots; i++) {
      double lat = _kathmandu_min_lat + random.nextDouble() * (_kathmandu_max_lat - _kathmandu_min_lat);
      double lng = _kathmandu_min_lng + random.nextDouble() * (_kathmandu_max_lng - _kathmandu_min_lng);
      
      String id = 'parking_${spots.length + 1}';
      String name = _parkingNames[random.nextInt(_parkingNames.length)];
      if (spots.any((spot) => spot.name == name)) {
        name = '$name ${spots.length + 1}';  // Make name unique
      }
      
      String address = '${random.nextInt(100) + 1}, Random Road, Kathmandu';
      int capacity = (random.nextInt(10) + 1) * 10;
      int availableSpots = random.nextDouble() < 0.1 ? 0 : random.nextInt(capacity + 1);
      int rate = (random.nextInt(9) + 2) * 10;
      String rateStr = 'Rs. $rate/hr';
      String openHours = random.nextDouble() < 0.7 ? '24 hours' : '6:00 AM - 10:00 PM';
      double rating = 3.0 + random.nextDouble() * 2.0;
      rating = double.parse(rating.toStringAsFixed(1));
      
      int featureCount = random.nextInt(4) + 3;
      List<String> shuffledFeatures = List<String>.from(_parkingFeatures)..shuffle();
      List<String> features = shuffledFeatures.take(featureCount).toList();
      
      spots.add(
        ParkingSpot(
          id: id,
          name: name,
          address: address,
          latitude: lat,
          longitude: lng,
          capacity: capacity,
          availableSpots: availableSpots,
          rate: rateStr,
          openHours: openHours,
          rating: rating,
          features: features,
          updatedAt: DateTime.now(),
        ),
      );
    }
    
    _parkingSpots = spots;
  }

  // Get nearby parking spots (sorted by distance)
  Future<List<ParkingSpot>> getNearbyParkingSpots(double latitude, double longitude) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // If we don't have any spots, generate them
    if (_parkingSpots.isEmpty) {
      _generateRandomParkingSpots();
    }
    
    // Update available spots randomly (to simulate real-time changes)
    _updateAvailableSpotsRandomly();
    
    // Sort by distance from the given coordinates
    _parkingSpots.sort((a, b) {
      double distA = a.distanceFrom(latitude, longitude);
      double distB = b.distanceFrom(latitude, longitude);
      return distA.compareTo(distB);
    });
    
    return _parkingSpots;
  }
  
  // Update available spots randomly to simulate real-time changes
  void _updateAvailableSpotsRandomly() {
    final random = Random();
    
    for (int i = 0; i < _parkingSpots.length; i++) {
      // 30% chance of updating each parking spot
      if (random.nextDouble() < 0.3) {
        ParkingSpot spot = _parkingSpots[i];
        
        // Calculate new available spots
        int change = random.nextInt(3) - 1;  // -1, 0, or +1
        int newAvailableSpots = (spot.availableSpots + change).clamp(0, spot.capacity);
        
        if (newAvailableSpots != spot.availableSpots) {
          _parkingSpots[i] = spot.copyWith(
            availableSpots: newAvailableSpots,
            updatedAt: DateTime.now(),
          );
        }
      }
    }
    
    notifyListeners();
  }
  
  // Get a specific parking spot by ID
  Future<ParkingSpot?> getParkingSpotById(String id) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _parkingSpots.firstWhere(
      (spot) => spot.id == id,
      orElse: () => throw Exception('Parking spot not found'),
    );
  }
  
  // Refresh parking data
  Future<void> refreshParkingData() async {
    _updateAvailableSpotsRandomly();
    notifyListeners();
    return Future.value();
  }
  
  // Book a parking spot
  Future<bool> bookParkingSpot(String spotId) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    int index = _parkingSpots.indexWhere((spot) => spot.id == spotId);
    if (index == -1) {
      return false;
    }
    
    ParkingSpot spot = _parkingSpots[index];
    if (spot.availableSpots <= 0) {
      return false;
    }
    
    _parkingSpots[index] = spot.copyWith(
      availableSpots: spot.availableSpots - 1,
      updatedAt: DateTime.now(),
    );
    
    notifyListeners();
    return true;
  }
}
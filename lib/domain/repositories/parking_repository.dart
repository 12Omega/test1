// lib/domain/repositories/parking_repository.dart
import 'package:dartz/dartz.dart';
import 'package:smart_parking_app/core/errors/failures.dart';
import 'package:smart_parking_app/domain/entities/parking_spot_entity.dart';

abstract class ParkingRepository {
  /// Get nearby parking spots based on provided location
  Future<Either<Failure, List<ParkingSpotEntity>>> getNearbyParkingSpots(
    double latitude, 
    double longitude
  );
  
  /// Get parking spot details by ID
  Future<Either<Failure, ParkingSpotEntity>> getParkingSpotById(String id);
  
  /// Refresh parking data (update available spots)
  Future<Either<Failure, void>> refreshParkingData();
  
  /// Get all parking spots (not sorted by distance)
  Future<Either<Failure, List<ParkingSpotEntity>>> getAllParkingSpots();
  
  /// Search parking spots by name or address
  Future<Either<Failure, List<ParkingSpotEntity>>> searchParkingSpots(String query);
  
  /// Filter parking spots by availability, features, etc.
  Future<Either<Failure, List<ParkingSpotEntity>>> filterParkingSpots({
    bool? hasAvailableSpots,
    List<String>? features,
    double? maxRate,
    bool? isOpen24Hours,
  });
}
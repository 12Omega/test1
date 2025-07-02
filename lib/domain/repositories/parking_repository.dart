// lib/domain/repositories/parking_repository.dart
import 'package:dartz/dartz.dart';
import 'package:smart_parking_app/core/errors/failures.dart';
import 'package:smart_parking_app/domain/entities/parking_spot_entity.dart';

abstract class ParkingRepository {
  /// Get nearby parking spots based on provided location
  Future<Either<Failure, List<ParkingSpotEntity>>> getNearbyParkingSpots(
      double latitude,
      double longitude,
      {double? radius} // Added optional radius
      );

  /// Get parking spot details by ID
  Future<Either<Failure, ParkingSpotEntity>> getParkingSpotById(String id);

  /// Refresh parking data (update available spots)
  Future<Either<Failure, void>> refreshParkingData();

  /// Get all parking spots (not sorted by distance)
  Future<Either<Failure, List<ParkingSpotEntity>>> getAllParkingSpots();

  /// Search parking spots by name or address
  Future<Either<Failure, List<ParkingSpotEntity>>> searchParkingSpots(String query);

  /// Filter parking spots by various criteria
  Future<Either<Failure, List<ParkingSpotEntity>>> getParkingSpotsByFilter({
    double? minRating,
    List<String>? requiredFeatures,
    String? sortBy, // e.g., "distance", "price", "rating"
    bool? ascending,
  });

  /// Get real-time updates for a parking spot
  Stream<ParkingSpotEntity> getParkingSpotUpdates(String spotId);
  // TODO: Consider if this should be Stream<Either<Failure, ParkingSpotEntity>> if the stream can error out in a way that needs a Failure type

  /// Get available spots count for a specific parking spot
  Future<Either<Failure, int>> getAvailableSpotsCount(String spotId);
}
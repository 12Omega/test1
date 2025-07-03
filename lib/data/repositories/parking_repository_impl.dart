// lib/data/repositories/parking_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:smart_parking_app/core/errors/exceptions.dart';
import 'package:smart_parking_app/core/errors/failures.dart';
import 'package:smart_parking_app/domain/entities/parking_spot_entity.dart';
import 'package:smart_parking_app/domain/repositories/parking_repository.dart';
import 'package:smart_parking_app/services/parking_service.dart';
// Ensure ParkingSpot model has a toEntity() method and necessary imports if not already present
// For example: import 'package:smart_parking_app/models/parking_spot.dart';


class ParkingRepositoryImpl implements ParkingRepository {
  final ParkingService parkingService;

  ParkingRepositoryImpl({
    required this.parkingService,
  });

  @override
  Future<Either<Failure, List<ParkingSpotEntity>>> getNearbyParkingSpots(
      double latitude, double longitude, {double? radius}) async {
    try {
      // ParkingService.getNearbyParkingSpots does not accept radius.
      // If radius functionality is needed, ParkingService must be updated.
      // For now, calling without radius.
      final parkingSpotModels = await parkingService.getNearbyParkingSpots(latitude, longitude);
      final parkingSpotEntities = parkingSpotModels.map((model) => model.toEntity()).toList();
      return Right(parkingSpotEntities);
    } on LocationException catch (e) {
      return Left(LocationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParkingSpotEntity>> getParkingSpotById(String id) async {
    try {
      final parkingSpotModel = await parkingService.getParkingSpotById(id);
      if (parkingSpotModel == null) {
        return Left(NotFoundFailure(message: 'Parking spot with id $id not found'));
      }
      return Right(parkingSpotModel.toEntity());
    } catch (e) {
      if (e.toString().contains('Parking spot not found')) {
        return Left(NotFoundFailure(message: 'Parking spot with id $id not found'));
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> refreshParkingData() async {
    try {
      await parkingService.refreshParkingData();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParkingSpotEntity>>> getAllParkingSpots() async {
    try {
      final parkingSpotModels = parkingService.parkingSpots;
      final parkingSpotEntities = parkingSpotModels.map((model) => model.toEntity()).toList();
      return Right(parkingSpotEntities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParkingSpotEntity>>> searchParkingSpots(String query) async {
    print("Warning: ParkingService.searchParkingSpots is not implemented. Returning empty list.");
    await Future.delayed(const Duration(milliseconds: 50));
    return Right([]);
  }

  @override
  Future<Either<Failure, List<ParkingSpotEntity>>> getParkingSpotsByFilter({
    double? minRating,
    List<String>? requiredFeatures,
    String? sortBy,
    bool? ascending,
  }) async {
    print("Warning: ParkingService.getParkingSpotsByFilter is not implemented. Returning empty list.");
    await Future.delayed(const Duration(milliseconds: 50));
    return Right([]);
  }

  @override
  Stream<ParkingSpotEntity> getParkingSpotUpdates(String spotId) {
    print("Warning: ParkingService.getSpotUpdates is not implemented. Returning empty stream.");
    return Stream.empty();
  }

  @override
  Future<Either<Failure, int>> getAvailableSpotsCount(String spotId) async {
    try {
      final parkingSpotModel = await parkingService.getParkingSpotById(spotId);
      if (parkingSpotModel == null) {
        return Left(NotFoundFailure(message: 'Parking spot with id $spotId not found'));
      }
      return Right(parkingSpotModel.availableSpots);
    } catch (e) {
      if (e.toString().contains('Parking spot not found')) {
        return Left(NotFoundFailure(message: 'Parking spot with id $spotId not found'));
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
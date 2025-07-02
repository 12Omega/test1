// lib/data/repositories/parking_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:smart_parking_app/core/errors/exceptions.dart';
import 'package:smart_parking_app/core/errors/failures.dart';
import 'package:smart_parking_app/domain/entities/parking_spot_entity.dart';
import 'package:smart_parking_app/domain/repositories/parking_repository.dart';
import 'package:smart_parking_app/services/parking_service.dart';

class ParkingRepositoryImpl implements ParkingRepository {
  final ParkingService parkingService;

  ParkingRepositoryImpl({
    required this.parkingService,
  });

  @override
  Future<Either<Failure, List<ParkingSpotEntity>>> getNearbyParkingSpots(
      double latitude, double longitude, {double? radius}) async {
    try {
      // Pass radius to service. Service needs to be updated to use it.
      final parkingSpotModels = await parkingService.getNearbyParkingSpots(latitude, longitude, radius: radius);
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
      // Catching generic Exception from service if spot not found
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
      final parkingSpotModels = await parkingService.getAllParkingSpots();
      final parkingSpotEntities = parkingSpotModels.map((model) => model.toEntity()).toList();
      return Right(parkingSpotEntities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParkingSpotEntity>>> searchParkingSpots(String query) async {
    try {
      final parkingSpotModels = await parkingService.searchParkingSpots(query);
      final parkingSpotEntities = parkingSpotModels.map((model) => model.toEntity()).toList();
      return Right(parkingSpotEntities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParkingSpotEntity>>> getParkingSpotsByFilter({
    double? minRating,
    List<String>? requiredFeatures,
    String? sortBy,
    bool? ascending,
  }) async {
    try {
      // Ensure parkingService has a matching method or adapt the call.
      // For now, assuming parkingService will be updated to have getParkingSpotsByFilter.
      final parkingSpotModels = await parkingService.getParkingSpotsByFilter(
        minRating: minRating,
        requiredFeatures: requiredFeatures,
        sortBy: sortBy,
        ascending: ascending,
      );
      final parkingSpotEntities = parkingSpotModels.map((model) => model.toEntity()).toList();
      return Right(parkingSpotEntities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<ParkingSpotEntity> getParkingSpotUpdates(String spotId) {
    // This is a basic implementation. A real app might use WebSockets or Firestore streams.
    // Listen to changes in ParkingService and emit new entity if the spotId matches.
    return parkingService.getSpotUpdates(spotId).map((parkingSpotModel) {
      if (parkingSpotModel == null) {
        // If the model is null (e.g. spot removed or error), we might want to throw an error
        // or emit a specific error state if the Stream was Stream<Either<Failure, ParkingSpotEntity>>
        throw Exception('Parking spot $spotId not found or removed during update.');
      }
      return parkingSpotModel.toEntity();
    });
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
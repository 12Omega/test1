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
      double latitude, double longitude) async {
    try {
      final parkingSpots = await parkingService.getNearbyParkingSpots(latitude, longitude);
      return Right(parkingSpots);
    } on LocationException catch (e) {
      return Left(LocationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParkingSpotEntity>> getParkingSpotById(String id) async {
    try {
      final parkingSpot = await parkingService.getParkingSpotById(id);
      return Right(parkingSpot);
    } catch (e) {
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
      final parkingSpots = await parkingService.getAllParkingSpots();
      return Right(parkingSpots);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParkingSpotEntity>>> searchParkingSpots(String query) async {
    try {
      final parkingSpots = await parkingService.searchParkingSpots(query);
      return Right(parkingSpots);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParkingSpotEntity>>> filterParkingSpots({
    bool? hasAvailableSpots,
    List<String>? features,
    double? maxRate,
    bool? isOpen24Hours,
  }) async {
    try {
      final parkingSpots = await parkingService.filterParkingSpots(
        hasAvailableSpots: hasAvailableSpots,
        features: features,
        maxRate: maxRate,
        isOpen24Hours: isOpen24Hours,
      );
      return Right(parkingSpots);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
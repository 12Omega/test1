// lib/domain/usecases/parking_usecases.dart
import '../entities/parking_spot_entity.dart';
import '../repositories/parking_repository.dart';

class GetNearbyParkingSpotsUseCase {
  final ParkingRepository repository;

  GetNearbyParkingSpotsUseCase(this.repository);

  Future<List<ParkingSpotEntity>> execute(double latitude, double longitude, {double radius = 5.0}) {
    return repository.getNearbyParkingSpots(latitude, longitude, radius: radius);
  }
}

class GetParkingSpotByIdUseCase {
  final ParkingRepository repository;

  GetParkingSpotByIdUseCase(this.repository);

  Future<ParkingSpotEntity> execute(String id) {
    return repository.getParkingSpotById(id);
  }
}

class SearchParkingSpotsUseCase {
  final ParkingRepository repository;

  SearchParkingSpotsUseCase(this.repository);

  Future<List<ParkingSpotEntity>> execute(String query) {
    return repository.searchParkingSpots(query);
  }
}

class GetParkingSpotUpdatesUseCase {
  final ParkingRepository repository;

  GetParkingSpotUpdatesUseCase(this.repository);

  Stream<ParkingSpotEntity> execute(String spotId) {
    return repository.getParkingSpotUpdates(spotId);
  }
}

class GetAvailableSpotsCountUseCase {
  final ParkingRepository repository;

  GetAvailableSpotsCountUseCase(this.repository);

  Future<int> execute(String spotId) {
    return repository.getAvailableSpotsCount(spotId);
  }
}

class FilterParkingSpotsUseCase {
  final ParkingRepository repository;

  FilterParkingSpotsUseCase(this.repository);

  Future<List<ParkingSpotEntity>> execute({
    double? minRating,
    List<String>? requiredFeatures,
    String? sortBy,
    bool? ascending,
  }) {
    return repository.getParkingSpotsByFilter(
      minRating: minRating,
      requiredFeatures: requiredFeatures,
      sortBy: sortBy,
      ascending: ascending,
    );
  }
}
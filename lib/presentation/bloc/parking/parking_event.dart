// lib/presentation/bloc/parking/parking_event.dart
import 'package:equatable/equatable.dart';

abstract class ParkingEvent extends Equatable {
  const ParkingEvent();

  @override
  List<Object?> get props => [];
}

class LoadNearbyParkingSpotsEvent extends ParkingEvent {
  final double latitude;
  final double longitude;

  const LoadNearbyParkingSpotsEvent({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class GetParkingSpotByIdEvent extends ParkingEvent {
  final String id;

  const GetParkingSpotByIdEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class RefreshParkingDataEvent extends ParkingEvent {}

class LoadAllParkingSpotsEvent extends ParkingEvent {}

class SearchParkingSpotsEvent extends ParkingEvent {
  final String query;

  const SearchParkingSpotsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class FilterParkingSpotsEvent extends ParkingEvent {
  final double? minRating;
  final List<String>? requiredFeatures;
  final String? sortBy;
  final bool? ascending;

  const FilterParkingSpotsEvent({
    this.minRating,
    this.requiredFeatures,
    this.sortBy,
    this.ascending,
  });

  @override
  List<Object?> get props => [minRating, requiredFeatures, sortBy, ascending];
}
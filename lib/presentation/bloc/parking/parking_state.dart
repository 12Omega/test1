// lib/presentation/bloc/parking/parking_state.dart
import 'package:equatable/equatable.dart';
import 'package:smart_parking_app/domain/entities/parking_spot_entity.dart';

abstract class ParkingState extends Equatable {
  const ParkingState();

  @override
  List<Object?> get props => [];
}

class ParkingInitial extends ParkingState {}

class ParkingLoading extends ParkingState {}

class ParkingLoaded extends ParkingState {
  final List<ParkingSpotEntity> parkingSpots;

  const ParkingLoaded({required this.parkingSpots});

  @override
  List<Object?> get props => [parkingSpots];
}

class ParkingSpotLoaded extends ParkingState {
  final ParkingSpotEntity parkingSpot;

  const ParkingSpotLoaded({required this.parkingSpot});

  @override
  List<Object?> get props => [parkingSpot];
}

class ParkingError extends ParkingState {
  final String message;

  const ParkingError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ParkingRefreshing extends ParkingState {}

class ParkingRefreshSuccess extends ParkingState {}

class ParkingRefreshError extends ParkingState {
  final String message;

  const ParkingRefreshError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ParkingSearching extends ParkingState {}

class ParkingFiltering extends ParkingState {}

class ParkingNoResults extends ParkingState {
  final String message;

  const ParkingNoResults({required this.message});

  @override
  List<Object?> get props => [message];
}
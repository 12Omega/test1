// lib/presentation/bloc/parking/parking_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_parking_app/domain/repositories/parking_repository.dart';
import 'package:smart_parking_app/presentation/bloc/parking/parking_event.dart';
import 'package:smart_parking_app/presentation/bloc/parking/parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final ParkingRepository parkingRepository;

  ParkingBloc({required this.parkingRepository}) : super(ParkingInitial()) {
    on<LoadNearbyParkingSpotsEvent>(_onLoadNearbyParkingSpots);
    on<GetParkingSpotByIdEvent>(_onGetParkingSpotById);
    on<RefreshParkingDataEvent>(_onRefreshParkingData);
    on<LoadAllParkingSpotsEvent>(_onLoadAllParkingSpots);
    on<SearchParkingSpotsEvent>(_onSearchParkingSpots);
    on<FilterParkingSpotsEvent>(_onFilterParkingSpots);
  }

  Future<void> _onLoadNearbyParkingSpots(
    LoadNearbyParkingSpotsEvent event,
    Emitter<ParkingState> emit,
  ) async {
    emit(ParkingLoading());
    
    final result = await parkingRepository.getNearbyParkingSpots(
      event.latitude,
      event.longitude,
    );
    
    result.fold(
      (failure) => emit(ParkingError(message: failure.message)),
      (parkingSpots) {
        if (parkingSpots.isEmpty) {
          emit(const ParkingNoResults(
            message: 'No parking spots found nearby',
          ));
        } else {
          emit(ParkingLoaded(parkingSpots: parkingSpots));
        }
      },
    );
  }

  Future<void> _onGetParkingSpotById(
    GetParkingSpotByIdEvent event,
    Emitter<ParkingState> emit,
  ) async {
    emit(ParkingLoading());
    
    final result = await parkingRepository.getParkingSpotById(event.id);
    
    result.fold(
      (failure) => emit(ParkingError(message: failure.message)),
      (parkingSpot) => emit(ParkingSpotLoaded(parkingSpot: parkingSpot)),
    );
  }

  Future<void> _onRefreshParkingData(
    RefreshParkingDataEvent event,
    Emitter<ParkingState> emit,
  ) async {
    emit(ParkingRefreshing());
    
    final result = await parkingRepository.refreshParkingData();
    
    result.fold(
      (failure) => emit(ParkingRefreshError(message: failure.message)),
      (_) => emit(ParkingRefreshSuccess()),
    );
    
    // After refreshing, reload the current state data
    if (state is ParkingLoaded) {
      add(LoadAllParkingSpotsEvent());
    }
  }

  Future<void> _onLoadAllParkingSpots(
    LoadAllParkingSpotsEvent event,
    Emitter<ParkingState> emit,
  ) async {
    emit(ParkingLoading());
    
    final result = await parkingRepository.getAllParkingSpots();
    
    result.fold(
      (failure) => emit(ParkingError(message: failure.message)),
      (parkingSpots) {
        if (parkingSpots.isEmpty) {
          emit(const ParkingNoResults(
            message: 'No parking spots available',
          ));
        } else {
          emit(ParkingLoaded(parkingSpots: parkingSpots));
        }
      },
    );
  }

  Future<void> _onSearchParkingSpots(
    SearchParkingSpotsEvent event,
    Emitter<ParkingState> emit,
  ) async {
    emit(ParkingSearching());
    
    final result = await parkingRepository.searchParkingSpots(event.query);
    
    result.fold(
      (failure) => emit(ParkingError(message: failure.message)),
      (parkingSpots) {
        if (parkingSpots.isEmpty) {
          emit(ParkingNoResults(
            message: 'No results found for "${event.query}"',
          ));
        } else {
          emit(ParkingLoaded(parkingSpots: parkingSpots));
        }
      },
    );
  }

  Future<void> _onFilterParkingSpots(
    FilterParkingSpotsEvent event,
    Emitter<ParkingState> emit,
  ) async {
    emit(ParkingFiltering());
    
    final result = await parkingRepository.filterParkingSpots(
      hasAvailableSpots: event.hasAvailableSpots,
      features: event.features,
      maxRate: event.maxRate,
      isOpen24Hours: event.isOpen24Hours,
    );
    
    result.fold(
      (failure) => emit(ParkingError(message: failure.message)),
      (parkingSpots) {
        if (parkingSpots.isEmpty) {
          emit(const ParkingNoResults(
            message: 'No spots match your filters',
          ));
        } else {
          emit(ParkingLoaded(parkingSpots: parkingSpots));
        }
      },
    );
  }
}
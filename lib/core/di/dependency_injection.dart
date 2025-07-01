// lib/core/di/dependency_injection.dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_parking_app/data/repositories/auth_repository_impl.dart';
import 'package:smart_parking_app/data/repositories/booking_repository_impl.dart';
import 'package:smart_parking_app/data/repositories/parking_repository_impl.dart';
import 'package:smart_parking_app/domain/repositories/auth_repository.dart';
import 'package:smart_parking_app/domain/repositories/booking_repository.dart';
import 'package:smart_parking_app/domain/repositories/parking_repository.dart';
import 'package:smart_parking_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:smart_parking_app/presentation/bloc/booking/booking_bloc.dart';
import 'package:smart_parking_app/presentation/bloc/parking/parking_bloc.dart';
import 'package:smart_parking_app/services/auth_service.dart';
import 'package:smart_parking_app/services/booking_service.dart';
import 'package:smart_parking_app/services/parking_service.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // Services
  sl.registerLazySingleton(() => AuthService());
  sl.registerLazySingleton(() => ParkingService());
  sl.registerLazySingleton(() => BookingService());
  
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authService: sl(),
      sharedPreferences: sl(),
    ),
  );
  
  sl.registerLazySingleton<ParkingRepository>(
    () => ParkingRepositoryImpl(
      parkingService: sl(),
    ),
  );
  
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(
      bookingService: sl(),
    ),
  );

  // BLoCs
  sl.registerFactory(
    () => AuthBloc(
      authRepository: sl(),
    ),
  );
  
  sl.registerFactory(
    () => ParkingBloc(
      parkingRepository: sl(),
    ),
  );
  
  sl.registerFactory(
    () => BookingBloc(
      bookingRepository: sl(),
    ),
  );
}
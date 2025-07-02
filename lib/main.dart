import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:smart_parking_app/core/di/dependency_injection.dart';
// import 'package:smart_parking_app/core/utils/constants.dart'; // Removed unused import
import 'package:smart_parking_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:smart_parking_app/presentation/bloc/auth/auth_event.dart';
import 'package:smart_parking_app/presentation/bloc/auth/auth_state.dart';
import 'package:smart_parking_app/presentation/bloc/booking/booking_bloc.dart';
import 'package:smart_parking_app/presentation/bloc/parking/parking_bloc.dart';
import 'package:smart_parking_app/screens/home_screen.dart';
import 'package:smart_parking_app/screens/login_screen.dart';
import 'package:smart_parking_app/services/booking_service.dart';
import 'package:smart_parking_app/services/parking_service.dart';
import 'package:smart_parking_app/utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize dependency injection
  await initDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
        ),
        BlocProvider<ParkingBloc>(
          create: (_) => sl<ParkingBloc>(),
        ),
        BlocProvider<BookingBloc>(
          create: (_) => sl<BookingBloc>(),
        ),
      ],
      child: MultiProvider(
        providers: [
          Provider<ParkingService>(create: (_) => sl<ParkingService>()),
          Provider<BookingService>(create: (_) => sl<BookingService>()),
        ],
        child: MaterialApp(
          title: 'Smart Parking App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: AppColors.primaryColor,
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: AppColors.primaryColor,
              secondary: AppColors.secondaryColor,
              surface: AppColors.background, // Use surface instead of background for ColorScheme
            ),
            scaffoldBackgroundColor: AppColors.background,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
              ),
              bodyMedium: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
              ),
              titleLarge: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
              titleMedium: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.white, // Assuming white text on primary app bar
              elevation: 0,
            ),
          ),
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              // Initialize auth state check
              if (state is AuthInitial) {
                context.read<AuthBloc>().add(CheckAuthStatusEvent());
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is Authenticated) { // Changed from AuthAuthenticated
                return const HomeScreen();
              } else {
                return const LoginScreen();
              }
            },
          ),
        ),
      ),
    );
  }
}
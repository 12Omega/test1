// lib/screens/map_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:smart_parking_app/core/utils/constants.dart'; // Unused
import 'package:smart_parking_app/domain/entities/parking_spot_entity.dart';
import 'package:smart_parking_app/presentation/bloc/parking/parking_bloc.dart';
import 'package:smart_parking_app/presentation/bloc/parking/parking_event.dart';
import 'package:smart_parking_app/presentation/bloc/parking/parking_state.dart';
import 'package:smart_parking_app/screens/parking_details_screen.dart';
import 'package:smart_parking_app/utils/app_colors.dart';
// import 'package:smart_parking_app/widgets/custom_button.dart'; // Unused
import 'package:smart_parking_app/widgets/search_bar_widget.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  bool _isLoading = true;
  bool _isMapCreated = false;
  Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _showFilterPanel = false;

  // Filter options
  bool? _availableSpotsOnly = true;
  double _maxPriceRate = 200;
  List<String> _selectedFeatures = [];
  bool? _open24Hours = false;

  final List<String> _availableFeatures = [
    'Covered Parking',
    'EV Charging',
    'Security Camera',
    'Wheelchair Accessible',
    'Car Wash'
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        context.read<ParkingBloc>().add(SearchParkingSpotsEvent(query: query));
      } else {
        _loadNearbyParkingSpots();
      }
    });
  }

  void _loadNearbyParkingSpots() {
    if (_currentPosition != null) {
      context.read<ParkingBloc>().add(
        LoadNearbyParkingSpotsEvent(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled. Please enable them in settings.'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isLoading = false;
        // Default to Kathmandu city center if location is not available
        _currentPosition = const LatLng(27.7172, 85.3240);
      });

      _loadParkingSpots();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are denied. Some features may be limited.'),
            backgroundColor: Colors.orange,
          ),
        );

        setState(() {
          _isLoading = false;
          // Default to Kathmandu city center if permission denied
          _currentPosition = const LatLng(27.7172, 85.3240);
        });

        _loadParkingSpots();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permissions are permanently denied. Please enable them in app settings.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isLoading = false;
        // Default to Kathmandu city center if permission permanently denied
        _currentPosition = const LatLng(27.7172, 85.3240);
      });

      _loadParkingSpots();
      return;
    }

    // When we reach here, permissions are granted and we can get the location
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _isLoading = false;
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      _loadParkingSpots();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isLoading = false;
        // Default to Kathmandu city center if error
        _currentPosition = const LatLng(27.7172, 85.3240);
      });

      _loadParkingSpots();
    }
  }

  void _loadParkingSpots() {
    if (_currentPosition != null) {
      context.read<ParkingBloc>().add(
        LoadNearbyParkingSpotsEvent(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
        ),
      );
    } else {
      context.read<ParkingBloc>().add(LoadAllParkingSpotsEvent());
    }
  }

  void _updateMarkers(List<ParkingSpotEntity> parkingSpots) {
    Set<Marker> markers = {};

    // Add current location marker if available
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // Add parking spot markers
    for (var spot in parkingSpots) {
      // Determine marker color based on availability
      final BitmapDescriptor markerIcon = spot.availableSpots > 0
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
          : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

      markers.add(
        Marker(
          markerId: MarkerId(spot.id),
          position: LatLng(spot.latitude, spot.longitude),
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: spot.name,
            snippet: 'Available: ${spot.availableSpots}/${spot.totalSpots} · ₹${spot.hourlyRate.toStringAsFixed(0)}/hour', // Changed to hourlyRate
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParkingDetailsScreen(parkingSpot: spot),
                ),
              );
            },
          ),
          onTap: () {
            // This is needed to show the info window
          },
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _applyFilters() {
    // TODO: Update UI to collect minRating, sortBy, ascending
    // For now, dispatching with some defaults or current best effort mapping
    context.read<ParkingBloc>().add(
      FilterParkingSpotsEvent(
        // hasAvailableSpots is not directly in new event, could be part of a custom filter logic if needed
        requiredFeatures: _selectedFeatures.isEmpty ? null : _selectedFeatures,
        // maxRate is not directly in new event.
        // minRating is new, default to null for now
        minRating: null,
        // sortBy is new, default to null (no specific sort) for now
        sortBy: null,
        // ascending is new, default to null (or true) for now
        ascending: true,
        // isOpen24Hours is not directly in new event.
      ),
    );

    setState(() {
      _showFilterPanel = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Parking'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Google Map
          _isLoading || _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: _currentPosition!,
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              if (!_isMapCreated) {
                _controller.complete(controller);
                setState(() {
                  _isMapCreated = true;
                });
              }
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
            zoomControlsEnabled: false,
            compassEnabled: true,
          ),

          // Top search bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                SearchBarWidget(
                  controller: _searchController,
                  hintText: 'Search for parking spots',
                  onChanged: _onSearch,
                  onFilterTap: () {
                    setState(() {
                      _showFilterPanel = !_showFilterPanel;
                    });
                  },
                ),
              ],
            ),
          ),

          // Filter panel
          if (_showFilterPanel)
            Positioned(
              top: 70,
              left: 16,
              right: 16,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Available spots only filter
                      SwitchListTile(
                        title: const Text('Show available spots only'),
                        value: _availableSpotsOnly ?? false,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setState(() {
                            _availableSpotsOnly = value;
                          });
                        },
                      ),

                      // 24-hour open filter
                      SwitchListTile(
                        title: const Text('Open 24 hours'),
                        value: _open24Hours ?? false,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setState(() {
                            _open24Hours = value;
                          });
                        },
                      ),

                      // Price range
                      const Text(
                        'Maximum hourly rate',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _maxPriceRate,
                              min: 50,
                              max: 500,
                              divisions: 9,
                              label: '₹${_maxPriceRate.toInt()}',
                              onChanged: (value) {
                                setState(() {
                                  _maxPriceRate = value;
                                });
                              },
                            ),
                          ),
                          Text('₹${_maxPriceRate.toInt()}'),
                        ],
                      ),

                      // Features
                      const Text(
                        'Features',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableFeatures.map((feature) {
                          final isSelected = _selectedFeatures.contains(feature);
                          return FilterChip(
                            label: Text(feature),
                            selected: isSelected,
                            selectedColor: AppColors.secondaryColor.withAlpha(51), // Replaced withOpacity(0.2)
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedFeatures.add(feature);
                                } else {
                                  _selectedFeatures.remove(feature);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _availableSpotsOnly = true;
                                _maxPriceRate = 200;
                                _selectedFeatures = [];
                                _open24Hours = false;
                              });
                            },
                            child: const Text('Reset'),
                          ),
                          ElevatedButton(
                            onPressed: _applyFilters,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                            ),
                            child: const Text(
                              'Apply',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bloc listener for states
          BlocConsumer<ParkingBloc, ParkingState>(
            listener: (context, state) {
              if (state is ParkingLoaded) {
                _updateMarkers(state.parkingSpots);
              } else if (state is ParkingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is ParkingNoResults) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            builder: (context, state) {
              // Show loading indicator when searching
              if (state is ParkingLoading || state is ParkingSearching || state is ParkingFiltering) {
                return const Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 16),
                            Text("Loading parking spots..."),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Bottom buttons for refresh and my location
          Positioned(
            bottom: 24,
            right: 16,
            child: Column(
              children: [
                // Refresh button
                FloatingActionButton(
                  onPressed: () {
                    context.read<ParkingBloc>().add(RefreshParkingDataEvent());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Refreshing parking data...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  heroTag: 'refresh_btn',
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.refresh,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                // My location button
                FloatingActionButton(
                  onPressed: () async {
                    if (_currentPosition != null && _isMapCreated) {
                      final GoogleMapController controller = await _controller.future;
                      controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: _currentPosition!,
                            zoom: 15,
                          ),
                        ),
                      );
                    }
                  },
                  heroTag: 'location_btn',
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.my_location,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
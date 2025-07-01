// lib/screens/parking_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_parking_app/core/utils/constants.dart';
import 'package:smart_parking_app/domain/entities/parking_spot_entity.dart';
import 'package:smart_parking_app/presentation/bloc/booking/booking_bloc.dart';
import 'package:smart_parking_app/presentation/bloc/booking/booking_event.dart';
import 'package:smart_parking_app/presentation/bloc/booking/booking_state.dart';
import 'package:smart_parking_app/screens/booking_confirmation_screen.dart';
import 'package:smart_parking_app/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class ParkingDetailsScreen extends StatefulWidget {
  final ParkingSpotEntity parkingSpot;

  const ParkingDetailsScreen({Key? key, required this.parkingSpot})
      : super(key: key);

  @override
  State<ParkingDetailsScreen> createState() => _ParkingDetailsScreenState();
}

class _ParkingDetailsScreenState extends State<ParkingDetailsScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _vehicleType = 'Car';
  final _vehiclePlateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double _totalAmount = 0;
  int _durationHours = 0;
  
  final List<String> _vehicleTypes = ['Car', 'Motorcycle', 'SUV', 'Van'];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _startTime = TimeOfDay.now();
    
    // Set default end time to 1 hour later
    final now = TimeOfDay.now();
    _endTime = TimeOfDay(
      hour: (now.hour + 1) % 24, 
      minute: now.minute,
    );
    
    _calculateTotalAmount();
  }

  @override
  void dispose() {
    _vehiclePlateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _calculateTotalAmount();
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        
        // If end time is before start time, adjust end time
        if (_endTime != null) {
          final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
          final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
          
          if (endMinutes <= startMinutes) {
            // Set end time to 1 hour after start time
            _endTime = TimeOfDay(
              hour: (_startTime!.hour + 1) % 24,
              minute: _startTime!.minute,
            );
          }
        }
      });
      _calculateTotalAmount();
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _endTime) {
      // Check that end time is after start time
      if (_startTime != null) {
        final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
        final pickedMinutes = picked.hour * 60 + picked.minute;
        
        if (pickedMinutes <= startMinutes) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('End time must be after start time'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      
      setState(() {
        _endTime = picked;
      });
      _calculateTotalAmount();
    }
  }

  void _calculateTotalAmount() {
    if (_selectedDate != null && _startTime != null && _endTime != null) {
      // Calculate hours between start and end time
      final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
      
      // If end time is on the same day
      int minutesDiff = endMinutes - startMinutes;
      if (minutesDiff <= 0) {
        // If end time is on the next day, add 24 hours
        minutesDiff += 24 * 60;
      }
      
      _durationHours = (minutesDiff / 60).ceil();
      _totalAmount = _durationHours * widget.parkingSpot.ratePerHour;
      
      // Apply vehicle type multiplier
      switch (_vehicleType) {
        case 'Motorcycle':
          _totalAmount *= 0.8; // 20% discount
          break;
        case 'SUV':
          _totalAmount *= 1.2; // 20% premium
          break;
        case 'Van':
          _totalAmount *= 1.5; // 50% premium
          break;
        default: // Car is default
          break;
      }
      
      setState(() {});
    }
  }

  void _proceedToBooking() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate == null || _startTime == null || _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select date and time for booking'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      
      final endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );
      
      // If end time is earlier than start time, it means it's on the next day
      if (endDateTime.isBefore(startDateTime)) {
        final nextDay = _selectedDate!.add(const Duration(days: 1));
        final newEndDateTime = DateTime(
          nextDay.year,
          nextDay.month,
          nextDay.day,
          _endTime!.hour,
          _endTime!.minute,
        );
        
        context.read<BookingBloc>().add(
              CreateBookingEvent(
                parkingSpotId: widget.parkingSpot.id,
                parkingSpotName: widget.parkingSpot.name,
                startTime: startDateTime,
                endTime: newEndDateTime,
                vehicleType: _vehicleType,
                vehiclePlate: _vehiclePlateController.text.trim(),
                amount: _totalAmount,
              ),
            );
      } else {
        context.read<BookingBloc>().add(
              CreateBookingEvent(
                parkingSpotId: widget.parkingSpot.id,
                parkingSpotName: widget.parkingSpot.name,
                startTime: startDateTime,
                endTime: endDateTime,
                vehicleType: _vehicleType,
                vehiclePlate: _vehiclePlateController.text.trim(),
                amount: _totalAmount,
              ),
            );
      }
    }
  }

  Future<void> _launchMapDirections() async {
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${widget.parkingSpot.latitude},${widget.parkingSpot.longitude}');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch map directions'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          
          if (state is BookingCreationSuccess) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => BookingConfirmationScreen(
                  booking: state.booking,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              // App bar with parking spot image
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Parking image or default background
                      widget.parkingSpot.imageUrl != null &&
                              widget.parkingSpot.imageUrl!.isNotEmpty
                          ? Image.network(
                              widget.parkingSpot.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/default_parking.jpg',
                              fit: BoxFit.cover,
                            ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      // Parking name at the bottom of the image
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Text(
                          widget.parkingSpot.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Parking spot details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Availability and price row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, 
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.parkingSpot.availableSpots > 0
                                    ? Colors.green
                                    : Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.parkingSpot.availableSpots > 0
                                    ? '${widget.parkingSpot.availableSpots}/${widget.parkingSpot.totalSpots} Available'
                                    : 'No spots available',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.attach_money,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                            Text(
                              '${widget.parkingSpot.ratePerHour}/hour',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Address and directions
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.parkingSpot.address,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _launchMapDirections,
                              icon: const Icon(
                                Icons.directions,
                                size: 18,
                              ),
                              label: const Text('Directions'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Features
                        const Text(
                          'Features',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.parkingSpot.features.map((feature) {
                            return Chip(
                              label: Text(feature),
                              backgroundColor: AppColors.background,
                              side: const BorderSide(
                                color: AppColors.borderColor,
                              ),
                              padding: EdgeInsets.zero,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ),
                            );
                          }).toList(),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Booking form
                        const Text(
                          'Book a Spot',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Date selection
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Date',
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              _selectedDate != null
                                  ? DateFormat('EEE, MMM d, yyyy')
                                      .format(_selectedDate!)
                                  : 'Select a date',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Time selection row
                        Row(
                          children: [
                            // Start time
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectStartTime(context),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Start Time',
                                    prefixIcon: const Icon(Icons.access_time),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    _startTime != null
                                        ? _startTime!.format(context)
                                        : 'Start',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // End time
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectEndTime(context),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'End Time',
                                    prefixIcon: const Icon(Icons.access_time),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    _endTime != null
                                        ? _endTime!.format(context)
                                        : 'End',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Vehicle type selection
                        DropdownButtonFormField<String>(
                          value: _vehicleType,
                          onChanged: (value) {
                            setState(() {
                              _vehicleType = value!;
                              _calculateTotalAmount();
                            });
                          },
                          items: _vehicleTypes
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Vehicle Type',
                            prefixIcon: const Icon(Icons.directions_car),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Vehicle plate
                        TextFormField(
                          controller: _vehiclePlateController,
                          decoration: InputDecoration(
                            labelText: 'Vehicle Plate Number',
                            hintText: 'Enter your license plate',
                            prefixIcon: const Icon(Icons.credit_card),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your vehicle plate number';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Duration and price summary
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Duration'),
                                  Text('$_durationHours hour(s)'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Vehicle Type'),
                                  Text(_vehicleType),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Rate'),
                                  Text('₹${widget.parkingSpot.ratePerHour}/hour'),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Amount',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '₹${_totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Book button
                        CustomButton(
                          text: state is BookingLoading
                              ? 'Processing...'
                              : 'Book Now',
                          isLoading: state is BookingLoading,
                          onPressed: widget.parkingSpot.availableSpots > 0 && 
                                    !(state is BookingLoading)
                              ? _proceedToBooking
                              : null,
                        ),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
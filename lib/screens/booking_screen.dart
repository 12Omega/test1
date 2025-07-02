// lib/screens/booking_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_parking_app/models/booking.dart';
import 'package:smart_parking_app/models/parking_spot.dart';
import 'package:smart_parking_app/screens/payment_screen.dart';
import 'package:smart_parking_app/services/booking_service.dart';
import 'package:smart_parking_app/utils/constants.dart';
import 'package:smart_parking_app/widgets/custom_button.dart';

class BookingScreen extends StatefulWidget {
  final ParkingSpot parkingSpot;

  const BookingScreen({
    Key? key,
    required this.parkingSpot,
  }) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  String _vehicleType = 'Car';
  // String _vehiclePlate = ''; // Removed as _plateController.text is used
  bool _isLoading = false;
  final List<String> _vehicleTypes = ['Motorcycle', 'Car', 'SUV', 'Van'];
  final TextEditingController _plateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  double get _hours {
    return _endDate.difference(_startDate).inMinutes / 60;
  }

  double get _totalAmount {
    // Extract rate value (e.g. "Rs. 60/hr" -> 60)
    final rateStr = widget.parkingSpot.rate;
    final rateValue = double.tryParse(
        rateStr.replaceAll(RegExp(r'[^0-9.]'), '')
    ) ?? 50; // Default to Rs. 50 if parsing fails

    return rateValue * _hours;
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = DateTime(
          _startDate.year,
          _startDate.month,
          _startDate.day,
          picked.hour,
          picked.minute,
        );

        // Ensure end time is at least 1 hour after start time
        if (_endDate.isBefore(_startDate.add(const Duration(hours: 1)))) {
          _endDate = _startDate.add(const Duration(hours: 1));
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endDate),
    );
    if (picked != null) {
      final newEndDate = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        picked.hour,
        picked.minute,
      );

      // Ensure end time is after start time
      if (newEndDate.isAfter(_startDate)) {
        setState(() {
          _endDate = newEndDate;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _proceedToPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final bookingService = Provider.of<BookingService>(context, listen: false);

      final booking = Booking(
        id: '', // Will be assigned by backend
        parkingSpotId: widget.parkingSpot.id,
        parkingSpotName: widget.parkingSpot.name,
        startTime: _startDate,
        endTime: _endDate,
        vehicleType: _vehicleType,
        vehiclePlate: _plateController.text.trim(),
        amount: _totalAmount,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
      );

      final createdBooking = await bookingService.createBooking(booking);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(booking: createdBooking.toEntity()),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create booking: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Parking'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Parking Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_parking,
                        size: 30,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.parkingSpot.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.parkingSpot.address,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _BookingInfoChip(
                                icon: Icons.monetization_on,
                                label: widget.parkingSpot.rate,
                              ),
                              const SizedBox(width: 8),
                              _BookingInfoChip(
                                icon: Icons.local_parking,
                                label: '${widget.parkingSpot.availableSpots} available',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Time Selection
              const Text(
                'Select Parking Time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _TimeSelection(
                      label: 'Start Time',
                      time: _startDate,
                      onTap: _selectStartTime,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TimeSelection(
                      label: 'End Time',
                      time: _endDate,
                      onTap: _selectEndTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Duration and Pricing Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Duration'),
                        Text(
                          '${_hours.toStringAsFixed(1)} hours',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Price'),
                        Text(
                          widget.parkingSpot.rate,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rs. ${_totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Vehicle Details
              const Text(
                'Vehicle Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _vehicleType,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car),
                ),
                items: _vehicleTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _vehicleType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Plate Number',
                  hintText: 'e.g. BA 1 PA 2345',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your vehicle plate number';
                  }
                  return null;
                },
                // onChanged removed as _plateController directly holds the value
              ),
              const SizedBox(height: 32),

              // Book Now Button
              CustomButton(
                label: 'Proceed to Payment',
                isLoading: _isLoading,
                onPressed: _proceedToPayment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeSelection extends StatelessWidget {
  final String label;
  final DateTime time;
  final VoidCallback onTap;

  const _TimeSelection({
    Key? key,
    required this.label,
    required this.time,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: kPrimaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('h:mm a').format(time),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEE, d MMM').format(time),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BookingInfoChip({
    Key? key,
    required this.icon,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
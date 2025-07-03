// lib/screens/booking_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
// import 'package:smart_parking_app/core/utils/constants.dart'; // Removed unused import
import 'package:smart_parking_app/domain/entities/booking_entity.dart';
// BookingStatus enum is now available via booking_entity.dart
import 'package:smart_parking_app/screens/home_screen.dart';
import 'package:smart_parking_app/utils/app_colors.dart';
import 'package:smart_parking_app/widgets/custom_button.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final BookingEntity booking;

  const BookingConfirmationScreen({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(26), // Replaced withOpacity(0.1)
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),

              // Confirmation message
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your parking spot has been booked successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // QR Code
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13), // Replaced withOpacity(0.05)
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: booking.id,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          booking.id.substring(0, 8).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: booking.id))
                                .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Booking ID copied to clipboard'),
                                ),
                              );
                            });
                          },
                          icon: const Icon(
                            Icons.copy,
                            size: 16,
                          ),
                          tooltip: 'Copy Booking ID',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Booking details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Parking Location', booking.parkingSpotName),
                    _buildDetailRow(
                      'Date',
                      DateFormat('EEE, MMM d, yyyy').format(booking.startTime),
                    ),
                    _buildDetailRow(
                      'Time',
                      '${DateFormat('h:mm a').format(booking.startTime)} - ${DateFormat('h:mm a').format(booking.endTime)}',
                    ),
                    _buildDetailRow('Vehicle Type', booking.vehicleType),
                    _buildDetailRow('Vehicle Plate', booking.vehiclePlate),
                    _buildDetailRow(
                      'Amount Paid',
                      '₹${booking.amount.toStringAsFixed(2)}',
                    ),
                    _buildDetailRow(
                      'Status',
                      _formatStatus(booking.status),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Instructions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.infoBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Instructions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Show this QR code at the parking entrance',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '2. Park at your designated spot',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '3. Return before your booking ends',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Done button
              CustomButton(
                label: 'Done', // Changed text to label
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Share booking button
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sharing booking details...'),
                    ),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Share Booking'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: const BorderSide(color: AppColors.primaryColor),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending: // Added pending from BookingEntity's enum
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
    // Removed 'active' as it's not in BookingEntity's BookingStatus enum
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      default: // This will catch any other values if they exist
        return status.toString().split('.').last; // Provides a default string like "pending"
    }
  }
}
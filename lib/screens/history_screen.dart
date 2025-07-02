// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:smart_parking_app/domain/entities/booking_entity.dart' as entities; // Removed unused import
import 'package:smart_parking_app/models/booking.dart' as models; // Import models for status mapping
import 'package:smart_parking_app/services/booking_service.dart';
import 'package:smart_parking_app/utils/constants.dart';
// TODO: Replace kPrimaryColor with AppColors.primaryColor if not defined in constants.dart
// import 'package:smart_parking_app/utils/app_colors.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  // Internally, this screen will now work with the `models.Booking` since it uses BookingService directly.
  // The BLoC/Repository layer would handle the entity conversion.
  // For a quick fix, I'll change the list types here.
  // A better fix would be to use a BLoC that returns BookingEntity.
  List<models.Booking> _activeBookings = [];
  List<models.Booking> _pastBookings = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final bookingService = Provider.of<BookingService>(context, listen: false);
      // bookingService.getUserBookings() returns Future<List<models.Booking>>
      final bookings = await bookingService.getUserBookings();

      final now = DateTime.now();

      if (mounted) {
        setState(() {
          _activeBookings = bookings.where((booking) {
            // Use models.BookingStatus here
            return booking.endTime.isAfter(now) &&
                booking.status != models.BookingStatus.cancelled;
          }).toList();

          _pastBookings = bookings.where((booking) {
            // Use models.BookingStatus here
            return booking.endTime.isBefore(now) ||
                booking.status == models.BookingStatus.cancelled;
          }).toList();

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load bookings: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // This mapping function might not be needed if the screen consistently uses models.Booking
  // models.BookingStatus _mapToModelStatus(entities.BookingStatus entityStatus) {
  //   switch (entityStatus) {
  //     case entities.BookingStatus.pending:
  //       return models.BookingStatus.pending;
  //     case entities.BookingStatus.confirmed:
  //       return models.BookingStatus.confirmed;
  //     case entities.BookingStatus.completed:
  //       return models.BookingStatus.completed;
  //     case entities.BookingStatus.cancelled:
  //       return models.BookingStatus.cancelled;
  //     default:
  //       return models.BookingStatus.pending;
  //   }
  // }

  Future<void> _cancelBooking(models.Booking booking) async { // Changed to models.Booking
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking? Cancellation fees may apply.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        setState(() => _isLoading = true);
        final bookingService = Provider.of<BookingService>(context, listen: false);
        // Use the original models.BookingStatus.cancelled here as that's what the service expects
        await bookingService.updateBookingStatus(booking.id, models.BookingStatus.cancelled);
        await _loadBookings(); // Refresh the list

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel booking: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: kPrimaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: kPrimaryColor,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Past'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadBookings,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
                : TabBarView(
              controller: _tabController,
              children: [
                // Active Tab
                _activeBookings.isEmpty
                    ? _buildEmptyState('You have no active bookings')
                    : _buildBookingsList(_activeBookings, true),

                // Past Tab
                _pastBookings.isEmpty
                    ? _buildEmptyState('No booking history found')
                    : _buildBookingsList(_pastBookings, false),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadBookings,
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List<models.Booking> bookings, bool isActive) { // Changed to models.Booking
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _BookingCard(
          booking: booking, // booking is now models.Booking
          isActive: isActive,
          onCancel: isActive ? () => _cancelBooking(booking) : null,
        );
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final models.Booking booking; // Changed to models.Booking
  final bool isActive;
  final VoidCallback? onCancel;

  const _BookingCard({
    Key? key,
    required this.booking,
    required this.isActive,
    this.onCancel,
  }) : super(key: key);

  Color _getStatusColor() {
    // booking.status is now models.BookingStatus
    switch (booking.status) {
      case models.BookingStatus.pending:
        return Colors.orange;
      case models.BookingStatus.confirmed:
      case models.BookingStatus.active: // models.BookingStatus has 'active'
        return Colors.green;
      case models.BookingStatus.cancelled:
        return Colors.red;
      case models.BookingStatus.completed:
        return Colors.blue;
      default: // Should not happen if all model statuses are covered
        return Colors.grey;
    }
  }

  String _getStatusText() {
    // booking.status is now models.BookingStatus
    switch (booking.status) {
      case models.BookingStatus.pending:
        return 'Pending';
      case models.BookingStatus.confirmed:
        return 'Confirmed';
      case models.BookingStatus.active:
        return 'Active';
      case models.BookingStatus.cancelled:
        return 'Cancelled';
      case models.BookingStatus.completed:
        return 'Completed';
      default: // Should not happen
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Booking Status Bar
          Container(
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Booking ID: ${booking.id.substring(0, 8).toUpperCase()}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Booking Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.local_parking,
                        color: kPrimaryColor,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.parkingSpotName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEE, d MMM yyyy').format(booking.startTime),
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DateFormat('h:mm a').format(booking.startTime)} - ${DateFormat('h:mm a').format(booking.endTime)}',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rs. ${booking.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _BookingInfoChip(
                      icon: Icons.directions_car,
                      label: booking.vehicleType,
                    ),
                    const SizedBox(width: 8),
                    _BookingInfoChip(
                      icon: Icons.credit_card,
                      label: booking.vehiclePlate,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          if (isActive && booking.status != models.BookingStatus.cancelled) // Use models.BookingStatus
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.cancel, size: 16),
                      label: const Text('Cancel Booking'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement view parking spot details
                      },
                      icon: const Icon(Icons.directions, size: 16),
                      label: const Text('Directions'),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
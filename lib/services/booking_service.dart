// lib/services/booking_service.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:smart_parking_app/models/booking.dart';

class BookingService extends ChangeNotifier {
  // In-memory storage for bookings
  List<Booking> _bookings = [];
  final Random _random = Random();

  // Get all bookings
  List<Booking> get bookings => _bookings; // Synchronous getter for all bookings

  // Get all bookings for a user (simulated)
  Future<List<Booking>> getUserBookings() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 700));
    // In a real app, this would filter by userId or fetch from a user-specific endpoint
    return List<Booking>.from(_bookings); // Return a copy
  }

  // Get upcoming bookings
  List<Booking> getUpcomingBookings() {
    return _bookings.where((booking) => booking.isUpcoming).toList();
  }

  // Get active bookings
  List<Booking> getActiveBookings() {
    return _bookings.where((booking) => booking.isActive).toList();
  }

  // Get past bookings
  List<Booking> getPastBookings() {
    return _bookings.where((booking) => booking.isPast).toList();
  }

  // Create a new booking
  Future<Booking> createBooking(Booking booking) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Generate a random ID for the booking
    final id = 'booking_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}';

    // Create a new booking with the generated ID and pending status
    final newBooking = booking.copyWith(
      id: id,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
    );

    _bookings.add(newBooking);
    notifyListeners();

    return newBooking;
  }

  // Get booking by ID
  Booking? getBookingById(String id) {
    try {
      return _bookings.firstWhere((booking) => booking.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update booking status
  Future<Booking> updateBookingStatus(String id, BookingStatus status) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 1000));

    final index = _bookings.indexWhere((booking) => booking.id == id);
    if (index == -1) {
      throw Exception('Booking not found');
    }

    final updatedBooking = _bookings[index].copyWith(status: status);
    _bookings[index] = updatedBooking;
    notifyListeners();

    return updatedBooking;
  }

  // Complete a payment for a booking
  Future<Booking> completePayment(String bookingId) async {
    // Simulate payment processing delay
    await Future.delayed(const Duration(milliseconds: 2000));

    // 5% chance of payment failure for simulation purposes
    if (_random.nextDouble() < 0.05) {
      throw Exception('Payment processing failed. Please try again.');
    }

    return updateBookingStatus(bookingId, BookingStatus.confirmed);
  }

  // Cancel a booking
  Future<Booking> cancelBooking(String id) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 1000));

    return updateBookingStatus(id, BookingStatus.cancelled);
  }

  // Get booking history
  Future<List<Booking>> getBookingHistory() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 1000));

    return _bookings.where((booking) =>
    booking.status == BookingStatus.completed ||
        booking.status == BookingStatus.cancelled
    ).toList();
  }
}
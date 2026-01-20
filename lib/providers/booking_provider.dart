import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  List<BookingModel> _bookings = [];
  bool _isLoading = false;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;

  final BookingService _bookingService = BookingService();

  Future<void> loadBookings(String userId, {bool isStudio = false}) async {
    _isLoading = true;
    notifyListeners();

    if (isStudio) {
      _bookings = await _bookingService.getStudioBookings(userId);
    } else {
      _bookings = await _bookingService.getArtistBookings(userId);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createBooking(BookingModel booking) async {
    try {
      await _bookingService.createBooking(booking);
      _bookings.add(booking);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateBookingStatus(
      String bookingId, BookingStatus status) async {
    await _bookingService.updateBookingStatus(bookingId, status);

    // Update local booking status
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(status: status);
    }

    notifyListeners();
  }
}

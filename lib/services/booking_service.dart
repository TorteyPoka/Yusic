import '../models/booking_model.dart';

class BookingService {
  // Sample bookings data for demo
  static final List<BookingModel> _mockBookings = [
    BookingModel(
      id: 'booking_001',
      studioId: 'studio_001',
      artistId: 'artist_005',
      sessionType: SessionType.recording,
      startTime: DateTime.now().add(const Duration(days: 2, hours: 10)),
      endTime: DateTime.now().add(const Duration(days: 2, hours: 13)),
      totalAmount: 3000.00,
      paidAmount: 1000.00,
      status: BookingStatus.confirmed,
      notes: 'Need vocal recording setup',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      paymentMethod: 'bKash',
      transactionId: 'TXN001234567',
    ),
    BookingModel(
      id: 'booking_002',
      studioId: 'studio_001',
      artistId: 'artist_006',
      sessionType: SessionType.jamming,
      startTime: DateTime.now().add(const Duration(days: 5, hours: 14)),
      endTime: DateTime.now().add(const Duration(days: 5, hours: 17)),
      totalAmount: 2400.00,
      paidAmount: 800.00,
      status: BookingStatus.pending,
      notes: 'Band practice session',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      paymentMethod: 'Nagad',
      transactionId: 'NGD987654321',
    ),
    BookingModel(
      id: 'booking_003',
      studioId: 'studio_001',
      artistId: 'artist_007',
      sessionType: SessionType.recording,
      startTime: DateTime.now().subtract(const Duration(days: 5, hours: 15)),
      endTime: DateTime.now().subtract(const Duration(days: 5, hours: 18)),
      totalAmount: 3600.00,
      paidAmount: 3600.00,
      status: BookingStatus.completed,
      notes: 'Album recording - completed successfully',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      paymentMethod: 'Rocket',
      transactionId: 'RKT555666777',
    ),
    BookingModel(
      id: 'booking_004',
      studioId: 'studio_001',
      artistId: 'artist_008',
      sessionType: SessionType.jamming,
      startTime: DateTime.now().add(const Duration(days: 7, hours: 18)),
      endTime: DateTime.now().add(const Duration(days: 7, hours: 21)),
      totalAmount: 2700.00,
      paidAmount: 900.00,
      status: BookingStatus.confirmed,
      notes: 'Evening jam session',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      paymentMethod: 'bKash',
      transactionId: 'TXN777888999',
    ),
  ];

  Future<List<BookingModel>> getStudioBookings(String studioId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockBookings.where((b) => b.studioId == studioId).toList();
  }

  Future<List<BookingModel>> getArtistBookings(String artistId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockBookings.where((b) => b.artistId == artistId).toList();
  }

  Future<void> createBooking(BookingModel booking) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockBookings.add(booking);
  }

  Future<void> updateBookingStatus(
      String bookingId, BookingStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockBookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _mockBookings[index] = _mockBookings[index].copyWith(status: status);
    }
  }

  Future<BookingModel?> getBookingById(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockBookings.firstWhere((b) => b.id == bookingId);
    } catch (e) {
      return null;
    }
  }
}

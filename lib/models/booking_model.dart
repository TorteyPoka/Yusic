import 'package:equatable/equatable.dart';

enum SessionType { recording, jamming }

enum BookingStatus { pending, confirmed, cancelled, completed }

class BookingModel extends Equatable {
  final String id;
  final String studioId;
  final String artistId;
  final SessionType sessionType;
  final DateTime startTime;
  final DateTime endTime;
  final double totalAmount;
  final double paidAmount;
  final BookingStatus status;
  final String? notes;
  final DateTime createdAt;
  final String? paymentMethod; // bKash, Nagad, Rocket
  final String? transactionId;

  const BookingModel({
    required this.id,
    required this.studioId,
    required this.artistId,
    required this.sessionType,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    this.notes,
    required this.createdAt,
    this.paymentMethod,
    this.transactionId,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      studioId: json['studioId'] as String,
      artistId: json['artistId'] as String,
      sessionType: SessionType.values.firstWhere(
        (e) => e.toString() == 'SessionType.${json['sessionType']}',
      ),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${json['status']}',
      ),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      paymentMethod: json['paymentMethod'] as String?,
      transactionId: json['transactionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studioId': studioId,
      'artistId': artistId,
      'sessionType': sessionType.toString().split('.').last,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'status': status.toString().split('.').last,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
    };
  }

  bool get isFullyPaid => paidAmount >= totalAmount;
  double get remainingAmount => totalAmount - paidAmount;

  BookingModel copyWith({
    String? id,
    String? studioId,
    String? artistId,
    SessionType? sessionType,
    DateTime? startTime,
    DateTime? endTime,
    double? totalAmount,
    double? paidAmount,
    BookingStatus? status,
    String? notes,
    DateTime? createdAt,
    String? paymentMethod,
    String? transactionId,
  }) {
    return BookingModel(
      id: id ?? this.id,
      studioId: studioId ?? this.studioId,
      artistId: artistId ?? this.artistId,
      sessionType: sessionType ?? this.sessionType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        studioId,
        artistId,
        sessionType,
        startTime,
        endTime,
        totalAmount,
        paidAmount,
        status,
        notes,
        createdAt,
        paymentMethod,
        transactionId,
      ];
}

import 'package:equatable/equatable.dart';

enum SlotStatus { available, booked, blocked }

class StudioScheduleModel extends Equatable {
  final String id;
  final String studioId;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final SlotStatus status;
  final String? bookingId;
  final SessionType? sessionType;

  const StudioScheduleModel({
    required this.id,
    required this.studioId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.bookingId,
    this.sessionType,
  });

  factory StudioScheduleModel.fromJson(Map<String, dynamic> json) {
    return StudioScheduleModel(
      id: json['id'] as String,
      studioId: json['studioId'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: TimeOfDay(
        hour: json['startHour'] as int,
        minute: json['startMinute'] as int,
      ),
      endTime: TimeOfDay(
        hour: json['endHour'] as int,
        minute: json['endMinute'] as int,
      ),
      status: SlotStatus.values.firstWhere(
        (e) => e.toString() == 'SlotStatus.${json['status']}',
      ),
      bookingId: json['bookingId'] as String?,
      sessionType: json['sessionType'] != null
          ? SessionType.values.firstWhere(
              (e) => e.toString() == 'SessionType.${json['sessionType']}',
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studioId': studioId,
      'date': date.toIso8601String(),
      'startHour': startTime.hour,
      'startMinute': startTime.minute,
      'endHour': endTime.hour,
      'endMinute': endTime.minute,
      'status': status.toString().split('.').last,
      'bookingId': bookingId,
      'sessionType': sessionType?.toString().split('.').last,
    };
  }

  @override
  List<Object?> get props => [
        id,
        studioId,
        date,
        startTime,
        endTime,
        status,
        bookingId,
        sessionType,
      ];
}

class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  String format() {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }
}

enum SessionType { recording, jamming }

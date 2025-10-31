import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String serviceId;
  final DateTime date;
  final String startTime; // "10:00"
  final String endTime; // "12:00"

  Booking({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory Booking.fromMap(String id, Map<String, dynamic> m) => Booking(
        id: id,
        userId: m['userId'],
        serviceId: m['serviceId'],
        date: (m['date'] as Timestamp).toDate(),
        startTime: m['startTime'],
        endTime: m['endTime'],
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'serviceId': serviceId,
        'date': date, // Firestore guarda DateTime como Timestamp
        'startTime': startTime,
        'endTime': endTime,
      };
}

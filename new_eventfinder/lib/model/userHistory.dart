import 'package:intl/intl.dart';

class UserHistory {
  final String eventId;
  final String uid;
  final String mapsUrl;
  final String imageUrl;
  final double rating;
  final String description;
  final String capacity;
  final String category;
  final String title;
  final String organizerType;
  final String status;
  final String participantStatus;
  final String location;
  final DateTime date;

  UserHistory({
    required this.eventId,
    required this.uid,
    required this.mapsUrl,
    required this.imageUrl,
    required this.rating,
    required this.description,
    required this.capacity,
    required this.category,
    required this.title,
    required this.organizerType,
    required this.status,
    required this.participantStatus,
    required this.location,
    required this.date,
  });

  factory UserHistory.fromJson(Map<String, dynamic> json) {
  return UserHistory(
    eventId: json['eventId'] ?? '',
    uid: json['uid'] ?? '',
    mapsUrl: json['mapsUrl'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    rating: (json['rating'] ?? 0).toDouble(),
    description: json['description'] ?? '',
    capacity: json['capacity'] ?? '',
    category: json['category'] ?? '',
    title: json['title'] ?? '',
    organizerType: json['organizerType'] ?? '',
    status: json['status'] ?? '',
    participantStatus: json['participantStatus']??'pending',
    location: json['location']??'',
    date: json['date'] != null
        ? DateFormat('dd/MM/yyyy HH:mm').parse(json['date'])
        : DateTime.now(), // Provide a default value if date is null
  );
}

  bool isPast() {
    return date.isBefore(DateTime.now());
  }
  bool isCanceled() {
    return status == "Canceled";
  }
}

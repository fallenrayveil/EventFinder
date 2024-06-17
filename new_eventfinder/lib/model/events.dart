import 'package:intl/intl.dart';

class Event {
  final String id;
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
  final String location;
  final DateTime date;

  Event({
    required this.id,
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
    required this.location,
    required this.date,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
  return Event(
    id: json['id'] ?? '',
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
    location: json['location']?? '',
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

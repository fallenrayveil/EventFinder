class Review {
  final String id;
  final String userId;
  final String eventId;
  final String userName;
  final String comment;
  final double rating;
  final DateTime date;

  Review({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // Parse the "date" field from seconds and nanoseconds into a DateTime object
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(json['date']['_seconds'] * 1000 +
        (json['date']['_nanoseconds'] / 1000000).round());
    
    return Review(
      id: json['id'],
      userId: json['userId'],
      eventId: json['eventId'],
      userName: json['userName'],
      comment: json['comment'],
      rating: json['rating'].toDouble(),
      date: dateTime,
    );
  }

 Map<String, dynamic> toJson() {
  return {
    'id': id,
    'userId': userId,
    'eventId': eventId,
    'userName': userName,
    'comment': comment,
    'rating': rating,
    'date': {
      '_seconds': date.millisecondsSinceEpoch ~/ 1000,  // Mengonversi milidetik ke detik
      '_nanoseconds': (date.microsecondsSinceEpoch % 1000000) * 1000,
    },
  };
}
}

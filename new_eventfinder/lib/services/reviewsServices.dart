import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/review.dart';
import '../config/config.dart';
import 'package:intl/intl.dart';

class ReviewService {
  static Future<List<Review>> fetchReviewsByEventId(String eventId) async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/events/$eventId/reviews'));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<Review> reviews = body.map((dynamic item) => Review.fromJson(item)).toList();
      return reviews;
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  static Future<Review> getReviewById(String eventId, String reviewId) async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/events/$eventId/reviews/$reviewId'));
    if (response.statusCode == 200) {
      return Review.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load review');
    }
  }

  static Future<void> addReview(Review review) async {
  final url = Uri.parse('${Config.apiUrl}/events/${review.eventId}/reviews');
  final body = jsonEncode({
    'userId': review.userId,
    'eventId': review.eventId,
    'userName': review.userName,
    'comment': review.comment,
    'rating': review.rating,
    'date': review.date.toIso8601String(),
  });

  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: body,
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to add review: ${response.body}');
  }
}

  static Future<void> updateReview(Review review) async {
  final url = Uri.parse('${Config.apiUrl}/events/${review.eventId}/reviews/${review.id}');
  final body = jsonEncode(review.toJson()); // Menggunakan toJson() dari Review
  
  final response = await http.put(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: body,
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update review: ${response.body}');
  }
}


  static Future<void> deleteReview(String eventId, String reviewId) async {
    final url = Uri.parse('${Config.apiUrl}/events/$eventId/reviews/$reviewId');

    final response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete review: ${response.body}');
    }
  }
}

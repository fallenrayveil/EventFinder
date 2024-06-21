import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:new_eventfinder/model/review.dart';
import 'package:new_eventfinder/services/reviewsServices.dart';
import 'package:new_eventfinder/services/participantService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'addReviewScreen.dart';

class ReviewListScreen extends StatefulWidget {
  final String eventId;

  ReviewListScreen({required this.eventId});

  @override
  _ReviewListScreenState createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  bool isLoading = true;
  List<Review> reviews = [];
  bool isParticipant = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchCurrentUser();
    await _fetchReviews();
    await _checkParticipantStatus();
  }

  Future<void> _fetchCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('uid');
    });
  }

  Future<void> _fetchReviews() async {
    try {
      List<Review> fetchedReviews = await ReviewService.fetchReviewsByEventId(widget.eventId);
      setState(() {
        reviews = fetchedReviews;
        isLoading = false;
      });
    } catch (error) {
      print(error);
      setState(() {
        isLoading = false;
      });
      // Handle error
    }
  }

  Future<void> _checkParticipantStatus() async {
    if (userId != null) {
      bool isPart = await ParticipantService.isParticipant(widget.eventId, userId!);
      setState(() {
        isParticipant = isPart;
      });
    }
  }

  bool canEditReview(String reviewUserId) {
    return userId == reviewUserId;
  }

  void editReview(Review review) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReviewScreen(eventId: widget.eventId, userId: userId!, reviewToEdit: review),
      ),
    ).then((_) => _fetchReviews());
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await ReviewService.deleteReview(widget.eventId, reviewId);
      _fetchReviews(); // Reload reviews after deletion
    } catch (error) {
      print('Failed to delete review: $error');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF30244D),
      leading: IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        // Handle back button press
        Navigator.pop(context);
      },
      color: Color(0xFFCBED54), // Warna tombol back
    ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return Card(
                        color: Color(0xFF30244D),
                        child: ListTile(
                          title: Text(review.userName,style: TextStyle(color: Color(0xFFCBED54)),),
                          subtitle: Text(review.comment,style: TextStyle(color: Color(0xFFCBED54))),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.yellow),
                              Text(review.rating.toString()),
                              if (canEditReview(review.userId))
                                IconButton(
                                  icon: Icon(Icons.edit,color: Color(0xFFCBED54),),
                                  onPressed: () => editReview(review),
                                ),
                              if (canEditReview(review.userId))
                                IconButton(
                                  icon: Icon(Icons.delete,color: Color(0xFFCBED54)),
                                  onPressed: () => deleteReview(review.id),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (isParticipant && reviews.isEmpty) // Show "Tambah Ulasan" only if participant and no reviews
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddReviewScreen(eventId: widget.eventId, userId: userId!),
                          ),
                        ).then((_) => _fetchReviews());
                      },
                      child: Text('Tambah Ulasan'),
                    ),
                  ),
              ],
            ),
    );
  }
}

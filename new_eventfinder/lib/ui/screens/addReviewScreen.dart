import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:new_eventfinder/model/review.dart';
import 'package:new_eventfinder/services/reviewsServices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../model/userProfille.dart'; // Sesuaikan dengan model UserProfile
import '../../services/userProfile.dart'; // Import ProfileService yang diperbarui

class AddReviewScreen extends StatefulWidget {
  final String eventId;
  final String userId;
  final Review? reviewToEdit; // Review to edit, optional

  AddReviewScreen({required this.eventId, required this.userId, this.reviewToEdit});

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 3;
  String? _userName;
  bool _isEditing = false; // Flag to indicate if editing mode

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    if (widget.reviewToEdit != null) {
      _isEditing = true;
      _populateFields();
    }
  }

  void _populateFields() {
    _commentController.text = widget.reviewToEdit!.comment;
    _rating = widget.reviewToEdit!.rating;
  }

  Future<void> _fetchUserName() async {
    try {
      String? userName = await ProfileService.fetchUserName(widget.userId);
      setState(() {
        _userName = userName ?? 'Anonymous'; // Fallback to 'Anonymous' if username is null
      });
    } catch (error) {
      print('Failed to fetch username: $error');
      setState(() {
        _userName = 'Anonymous'; // Fallback to 'Anonymous' on error
      });
    }
  }

  Future<void> _submitReview() async {
    if (_commentController.text.isEmpty) return;

    final review = Review(
      id: _isEditing ? widget.reviewToEdit!.id : Uuid().v4(),
      userId: widget.userId,
      eventId: widget.eventId,
      userName: _userName ?? 'Anonymous', // Use fetched username or fallback to 'Anonymous'
      comment: _commentController.text,
      rating: _rating,
      date: DateTime.now(),
    );

    try {
      if (_isEditing) {
        await ReviewService.updateReview(review);
      } else {
        await ReviewService.addReview(review);
      }
      Navigator.pop(context); // Close the screen after submitting review
    } catch (error) {
      // Handle error
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to ${_isEditing ? "update" : "add"} review: $error')));
    }
  }

  void _stopEditing() {
    setState(() {
      _isEditing = false; // Set editing mode to false
    });
    Navigator.pop(context); // Close the screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFF30244D),
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Ulasan' : 'Tambah Ulasan',style: TextStyle(color: Color(0xFFCBED54)),),
        backgroundColor:  Color(0xFF30244D),
        
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.close,color: Color(0xFFCBED54),),
              onPressed: _stopEditing,
            ),
            
        ],
        leading: IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        // Handle back button press
        Navigator.pop(context);
      },
      color: Color(0xFFCBED54), // Warna tombol back
    ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Rating', style: TextStyle(fontSize: 18, color: Color(0xFFCBED54))),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              style: TextStyle( color: Color(0xFFCBED54)),
              controller: _commentController,
              decoration: InputDecoration(labelText: 'Komentar',labelStyle: TextStyle( color: Color(0xFFCBED54))),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            if(!_isEditing)
            ElevatedButton(
              onPressed: _isEditing ? null : _submitReview, // Disable if editing
              child: Text(_isEditing ? 'Sunting Ulasan' : 'Kirim Ulasan'),
            ),
            SizedBox(height: 16),
            if(_isEditing)
            ElevatedButton(
              onPressed:(){ _submitReview();} , // Disable if editing
              child: Text(_isEditing ?  'Kirim Ulasan': 'Berhenti Edit' ),
              style:ElevatedButton.styleFrom(
                 backgroundColor: Color(0xFFCBED54)
              ),
            ),
          ],
        ),
      ),
    );
  }
}

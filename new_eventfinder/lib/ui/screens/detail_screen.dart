import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:new_eventfinder/model/events.dart';
import 'package:new_eventfinder/model/userProfille.dart';
import 'package:new_eventfinder/services/reviewsServices.dart';
import '../../services/participantService.dart';
import '../screens/participantListScreen.dart';
import 'package:new_eventfinder/services/userProfile.dart';
import '../../config/config.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../screens/reviewListScreen.dart'; // Import url_launcher


class EventDetailScreen extends StatefulWidget {
  final Event event;

  EventDetailScreen({required this.event});

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  UserProfile? userProfile;
  bool isLoading = true;
  bool isJoined = false;
  String currentUserId = '';
  SharedPreferences? prefs;
  int currentParticipants = 0; 
  String participantsId = '';
  late double currentRating; // New variable to hold current participants

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchCurrentUser();
    await _loadPreferences();
    await _fetchEventRating();
    await _fetchParticipants();
    await _checkIfJoined();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchEventRating() async {
  try {
    List<dynamic> reviews = await ReviewService.fetchReviewsByEventId(widget.event.id);
    
    if (reviews.isEmpty) {
      setState(() {
        currentRating = 0.0; // Jika tidak ada review, rating diatur menjadi 0
      });
      return;
    }

    double totalRating = reviews.fold(0, (previous, current) => previous + current.rating);
    double averageRating = totalRating / reviews.length;

    setState(() {
      currentRating = averageRating;
    });
  } catch (error) {
    // Handle error fetching reviews
    print('Failed to fetch reviews: $error');
  }
}


  Future<void> _loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _fetchParticipants() async {
  try {
    List<dynamic> participants = await ParticipantService.fetchParticipants(widget.event.id);
    final uid = prefs!.getString('uid') ?? '';
    setState(() {
      currentParticipants = participants
          .where((participant) =>
              participant.status != 'Rejected' &&
              participant.status != 'Cancelled')
          .length;

      final participant = participants.firstWhere(
        (participant) => participant['uid'] == uid,
         // Return null explicitly if no participant is found
      );

      if (participant != null) {
        participantsId = participant['id']; // Assuming 'id' is the field name for participant ID
        print(participantsId);
      } else {
        participantsId = ''; // Handle the case where the participant is not found
      }
    });
  } catch (error) {
    // Handle error
    print('Failed to fetch participants: $error');
  }
}



 Future<void> _joinOrCancelEvent() async {
  if (prefs == null) return;

  final uid = prefs!.getString('uid') ?? '';
  final email = prefs!.getString('email') ?? '';

  if (isJoined) {
    // Update participant status to 'cancelled'
    try {
      await ParticipantService.updateParticipantStatus(participantsId, 'Cancelled');

      // Show success message or navigate to success page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cancelled event successfully')),
      );

      setState(() {
        isJoined = false;
        currentParticipants--; // Decrease participant count
      });
    } catch (error) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel event: $error')),
      );
    }
  } else {
    // Join event
    try {
      // Check if the user is already a participant
      List<dynamic> participants = await ParticipantService.fetchParticipants(widget.event.id);
      print(participants);
      print('tempek');

      var existingParticipant;

      if (participants.isNotEmpty){
      existingParticipant = participants.firstWhere(
        (participant) => participant['uid'] == uid, // Return null explicitly if no participant is found
      );
      }
      
      
      print(existingParticipant);

      if (existingParticipant != null) {
        // Update the status of the existing participant to 'pending'
        
        await ParticipantService.updateParticipantStatus(existingParticipant['id'], 'pending'); // Assuming 'id' is the field name for participant ID
      } else {
        // If the participant is not already in the list, add them as a new participant
        
        UserProfile profile = await ProfileService.fetchUserProfile(uid);
        

        await ParticipantService.addParticipant(
          eventId: widget.event.id,
          uid: uid,
          email: email,
          name: profile.name,
          phone: profile.phone,
        );
      }

      

      // Show success message or navigate to success page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined event successfully')),
      );

      setState(() {
        isJoined = true;
        currentParticipants++; // Increase participant count
      });
    } catch (error) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join event: $error')),
      );
    }
  }
}




  Future<void> _fetchCurrentUser() async {
    prefs = await SharedPreferences.getInstance();
    String? uid = prefs?.getString('uid');
    if (uid != null) {
      setState(() {
        currentUserId = uid;
      });
    }
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      UserProfile profile = await ProfileService.fetchUserProfile(widget.event.uid);
      setState(() {
        userProfile = profile;
      });
    } catch (error) {
      // Handle error
    }
  }

  Future<void> _checkIfJoined() async {
    if (prefs == null) return;

    final uid = prefs!.getString('uid') ?? '';
    try {
      bool joined = await ParticipantService.isParticipant(widget.event.id, uid);
      print("join ga");
      print(joined);
      setState(() {
        isJoined = joined;
      });
    } catch (error) {
      // Handle error
      print('Failed to check if joined: $error');
    }
  }

  Future<void> _launchMapsUrl() async {
    final url = widget.event.mapsUrl;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor:  Color(0xFF30244D),
      appBar: AppBar(
      backgroundColor: Color(0xFF30244D),
      leading: IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        // Handle back button press
        Navigator.pop(context);
      },
      color: Color(0xFFCBED54), // Warna tombol back
    ),),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.0),
              children: <Widget>[
                Text(
                  widget.event.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFCBED54),
                  ),
                ),
                
                SizedBox(height: 16.0),
                Row(
                  children: <Widget>[
                    Icon(Icons.star, color: Colors.yellow),
                    Text(
                      currentRating > 0 ? currentRating.toString() : 'Belum ada rating',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Color(0xFFCBED54),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      widget.event.organizerType,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFCBED54),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage('${Config.apiUrl}/${userProfile?.profileImage ?? 'assets/image/welcome_image.png'}'),
                      radius: 20.0,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'By: ${userProfile != null ? userProfile!.name : 'Loading...'}',
                      style: TextStyle(
                        color: Color(0xFFCBED54),
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Image.network(
                  '${Config.apiUrl}${widget.event.imageUrl}',
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 16.0),
                Row(
                  children: <Widget>[
                    Icon(Icons.people, color: Color(0xFFCBED54)),
                    SizedBox(width: 8.0),
                    Text(
                      int.parse(widget.event.capacity) == 0 ? '$currentParticipants Orang Bergabung ': '$currentParticipants / ${widget.event.capacity} Orang Bergabung',
                      style: TextStyle(
                        color: Color(0xFFCBED54),
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: <Widget>[
                    Icon(Icons.schedule, color: Color(0xFFCBED54)),
                    SizedBox(width: 8.0),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(widget.event.date),
                      style: TextStyle(
                        color: Color(0xFFCBED54),
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: <Widget>[
                    Icon(Icons.location_city, color: Color(0xFFCBED54)),
                    SizedBox(width: 8.0),
                    Text(
                      widget.event.location,
                      style: TextStyle(
                        color: Color(0xFFCBED54),
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                GestureDetector(
                  onTap: _launchMapsUrl,  // Add this gesture detector
                  child: Text(
                    'Lihat Lokasi',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16.0,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  widget.event.description,
                  style: TextStyle(
                    color: Color(0xFFCBED54),
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 16.0),
                GestureDetector(
                  onTap: () {
                   Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewListScreen(eventId: widget.event.id),
      ),
    );
                  },
                  child: Text(
                    'Lihat Ulasan',
                    style: TextStyle(
                      color: Color(0xFFCBED54),
                      fontSize: 16.0,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParticipantListScreen(eventId: widget.event.id),
                      ),
                    );
                    
                  },
                  child: Text('Lihat Partisipan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCBED54)
                  ),
                ),
                SizedBox(height: 16.0),
                if (currentParticipants < int.parse(widget.event.capacity) || int.parse(widget.event.capacity) == 0)
                  if (currentUserId != widget.event.uid)
                    ElevatedButton(
                      
                      onPressed:  _joinOrCancelEvent ,
                      child: Text(isJoined ? 'Batal' : 'Join'),
                       style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCBED54)
                  ),
                    )
                  else
                    Container(),
                if (currentParticipants >= int.parse(widget.event.capacity) && int.parse(widget.event.capacity) != 0)
                  Text(
                    "Full",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
    );
  }
}

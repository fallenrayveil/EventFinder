import 'package:flutter/material.dart';
import 'package:new_eventfinder/config/config.dart';
import '../../model/events.dart';
import '../../services/eventService.dart';
import 'editEvent_screen.dart';
import 'package:intl/intl.dart';

final EventService _eventService = EventService();

class UserEventsScreen extends StatefulWidget {
  final String uid;

  UserEventsScreen({required this.uid});

  @override
  _UserEventsScreenState createState() => _UserEventsScreenState();
}

class _UserEventsScreenState extends State<UserEventsScreen> {
  late Future<List<Event>> futureEvents;

  @override
  void initState() {
    super.initState();
    futureEvents = _eventService.fetchUserEvents(widget.uid);
  }

  void _navigateToEditScreen(Event event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditEventScreen(event: event, uid: widget.uid)),
    );

    if (result == true) {
      setState(() {
        futureEvents = _eventService.fetchUserEvents(widget.uid);
      });
    }
  }

  void _deleteEvent(String eventId) async {
    try {
      await _eventService.deleteEvent(eventId);
      setState(() {
        futureEvents = _eventService.fetchUserEvents(widget.uid);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete event: $e')));
    }
  }

  String _getEventStatus(String status) {
    switch (status) {
      case 'Upcoming':
        return 'Upcoming';
      case 'Ongoing':
        return 'Ongoing';
      case 'Cancelled':
        return 'Cancelled';
      case 'Complete':
        return 'Complete';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Colors.green;
      case 'Ongoing':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      case 'Complete':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getEventTimeDescription(DateTime eventDate) {
   
    final now = DateTime.now();
    final difference = eventDate.difference(now);

    if (difference.inDays >= 30) {
      return '${difference.inDays ~/ 30} months';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} days';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hours';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minutes';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xFF30244D),
      leading: IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        // Handle back button press
        Navigator.pop(context);
      },
      color: Color(0xFFCBED54), // Warna tombol back
    ),),
      body: FutureBuilder<List<Event>>(
        future: futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Event event = snapshot.data![index];
                return Card(
                  color: Color(0xFF30244D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(color: Color(0xFFCBED54), width: 2),
                  ),
                  margin: EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      event.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15.0),
                                topRight: Radius.circular(15.0),
                              ),
                              child: Image.network(
                                '${Config.apiUrl}${event.imageUrl}',
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(),
                      ListTile(
                        title: Text(
                          event.title,
                          style: TextStyle(color: Color(0xFFCBED54), fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.description,
                              style: TextStyle(color: Color(0xFFCBED54)),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              _getEventTimeDescription(event.date),
                              style: TextStyle(color: Color(0xFFCBED54)),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              _getEventStatus(event.status),
                              style: TextStyle(color: _getStatusColor(event.status)),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Color(0xFFCBED54)),
                              onPressed: () => _navigateToEditScreen(event),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Color(0xFFCBED54)),
                              onPressed: () => _deleteEvent(event.id),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

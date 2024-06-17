import 'package:flutter/material.dart';
import 'package:new_eventfinder/config/config.dart';
import 'package:new_eventfinder/model/events.dart';
import 'package:new_eventfinder/model/userHistory.dart';
import 'package:new_eventfinder/services/historyServices.dart';
import 'package:new_eventfinder/ui/screens/detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Mendatang'),
            Tab(text: 'Selesai'),
            Tab(text: 'Batal'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          EventList(status: 'mendatang'),
          EventList(status: 'selesai'),
          EventList(status: 'batal'),
        ],
      ),
    );
  }
}

class EventList extends StatefulWidget {
  final String status;

  EventList({required this.status});

  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  late Future<List<UserHistory>> _futureEvents;
  SharedPreferences? _prefs;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _uid = _prefs?.getString('uid');
    if (_uid != null) {
      setState(() {
        _futureEvents = HistoryService().fetchUserEvents(_uid!);
      });
    } else {
      setState(() {
        _futureEvents = Future.error('User not logged in');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      // Handle case where uid is null (user not logged in?)
      return Center(child: Text('User not logged in'));
    }

    return FutureBuilder<List<UserHistory>>(
      future: _futureEvents,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No events found'));
        } else {
          List<UserHistory> filteredEvents = _filterEvents(snapshot.data!);
          return ListView.builder(
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              return EventCard(event: filteredEvents[index]);
            },
          );
        }
      },
    );
  }

  List<UserHistory> _filterEvents(List<UserHistory> events) {
    DateTime now = DateTime.now();
    List<UserHistory> filteredEvents;

    switch (widget.status) {
      case 'mendatang':
        filteredEvents = events.where((event) {
          DateTime eventDate = event.date;
          return (event.status == 'Upcoming' || event.status == 'Ongoing') && eventDate.isAfter(now);
        }).toList();
        break;
      case 'selesai':
        filteredEvents = events.where((event) {
          DateTime eventDate = event.date;
          return event.status == 'Finish' && eventDate.isBefore(now);
        }).toList();
        break;
      case 'batal':
        filteredEvents = events.where((event) {
          return event.status == 'Rejected' || event.status == 'Cancelled';
        }).toList();
        break;
      default:
        filteredEvents = [];
    }

    return filteredEvents;
  }
}

class EventCard extends StatelessWidget {
  final UserHistory event;

  EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(event.title),
        subtitle: Text('${event.date}\nOrganizer: ${event.organizerType}\nStatus: ${event.participantStatus}'),
        leading: Image.network(Config.apiUrl + event.imageUrl),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventDetailScreen(event: _convertToEvent(event))),
          );
        },
      ),
    );
  }

  Event _convertToEvent(UserHistory userHistory) {
    return Event(
      id: userHistory.eventId,
      uid: userHistory.uid,
      title: userHistory.title,
      description: userHistory.description,
      date: userHistory.date,
      organizerType: userHistory.organizerType,
      status: userHistory.status,
      category: userHistory.category,
      capacity: userHistory.capacity,
      imageUrl: userHistory.imageUrl,
      mapsUrl: userHistory.mapsUrl,
      rating: userHistory.rating,
      location: userHistory.location
    );
  }
}

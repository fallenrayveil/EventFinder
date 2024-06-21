import 'package:flutter/material.dart';
import 'package:new_eventfinder/ui/template/templateScreen.dart';
import '../widgets/topEventCard.dart';
import '../widgets/otherEventCard.dart';
import '../../services/eventService.dart';
import '../../model/events.dart';

class HomeScreen extends StatelessWidget {
  final EventService _eventService = EventService();
  late Future<List<Event>> _events;

  HomeScreen() {
    _events = _eventService.fetchEvents();
    _events.then((events) {
      print(events);  // Print data fetched
    }).catchError((error) {
      print('Error fetching events: $error');  // Print error if any
    });
  }
  

  @override
Widget build(BuildContext context) {
  return TemplateScreen(
    title: 'Home',
    child: FutureBuilder<List<Event>>(
      future: _events,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print(snapshot.error); // Print the actual error
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No events found'));
        }

        List<Event> events = snapshot.data!;
        List<Event> topEvents = events
            .where((event) => event.rating > 0)
            .toList()
          ..sort((a, b) => b.rating.compareTo(a.rating));
        List<Event> otherEvents = events
            .where((event) => !event.isPast())
            .toList();
        print('');print(topEvents);

        return ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Acara Top',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCBED54),
                ),
              ),
            ),
            Column(
              children: topEvents.map((event) => TopEventCard(event: event)).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Acara Lainnya',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCBED54),
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: otherEvents.length,
              itemBuilder: (BuildContext context, int index) {
                return OtherEventCard(event: otherEvents[index]);
              },
            ),
          ],
        );
      },
    ),
  );
}
}

void main() => runApp(MaterialApp(home: HomeScreen()));

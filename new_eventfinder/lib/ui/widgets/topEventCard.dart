import 'package:flutter/material.dart';
import 'package:new_eventfinder/config/config.dart';
import 'package:new_eventfinder/model/events.dart';
import '../screens/detail_screen.dart';
import 'package:intl/intl.dart';

class TopEventCard extends StatelessWidget {
  final Event event;

  TopEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(event: event),
          ),
        );
      },      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image.network(
              '${Config.apiUrl}${event.imageUrl}',
              height: 150,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                event.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Tanggal: ${DateFormat('dd/MM/yyyy HH:mm').format(event.date)}',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                event.isPast() ? 'Acara Telah Berlalu' : 'Acara Mendatang',
                style: TextStyle(
                  color: event.isPast() ? Colors.red : Colors.green,
                ),
              ),
            ),
            Padding(
            padding: const EdgeInsets.all(8.0),
            child: event.rating > 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.star,
                        color: Colors.yellow,
                      ),
                      SizedBox(width: 4),
                      Text(
                        event.rating.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Belum ada rating',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
          ),
          ],
        ),
      ),
    );
  }
}

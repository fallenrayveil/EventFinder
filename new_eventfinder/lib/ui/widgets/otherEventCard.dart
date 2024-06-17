import 'package:flutter/material.dart';
import 'package:new_eventfinder/config/config.dart';
import 'package:new_eventfinder/model/events.dart';
import 'package:new_eventfinder/ui/screens/detail_screen.dart';

class OtherEventCard extends StatelessWidget {
  final Event event;

  OtherEventCard({required this.event});

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
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Container(
                color: Color(0xFFCBED54), // warna placeholder gambar
                child: event.imageUrl.isNotEmpty
                    ? Image.network('${Config.apiUrl}${event.imageUrl}', fit: BoxFit.cover)
                    : Center(child: Icon(Icons.image)), // icon placeholder gambar
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                event.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF30244D),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                event.isPast() ? 'Acara Telah Berlalu' : 'Acara Mendatang',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
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

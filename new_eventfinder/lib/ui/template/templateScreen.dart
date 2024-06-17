import 'package:flutter/material.dart';

class TemplateScreen extends StatelessWidget {
  final String title;
  final Widget child;

  TemplateScreen({required this.title, required this.child});

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
    ),),
    backgroundColor: Color(0xFF30244D),
      body: child,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () {
                Navigator.pushNamed(context, '/calendar');
              },
            ),
            IconButton(
              icon: Icon(Icons.history),
              onPressed: () {
                Navigator.pushNamed(context, '/history');
              },
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () { Navigator.pushNamed(context, '/search');},
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.search),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () { Navigator.pushNamed(context, '/createEvent');},
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: TemplateScreen(
        title: 'Template Screen',
        child: Center(
          child: Text('Your content goes here'),
        ),
      ),
    ));

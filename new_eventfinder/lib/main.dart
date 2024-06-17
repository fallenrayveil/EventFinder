import 'package:new_eventfinder/ui/screens/calendar_screen.dart';
import 'package:new_eventfinder/ui/screens/createEvent_screen.dart';
import 'package:new_eventfinder/ui/screens/history_screens.dart';
import 'package:new_eventfinder/ui/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:new_eventfinder/ui/screens/searchScreen.dart';
import 'ui/screens/welcome_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/register_screen.dart';
import 'ui/screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventFinder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/login':(context)=>LoginScreen(),
        '/register':(context)=>RegisterScreen(),
        '/home':(context) => HomeScreen(),
        '/history':(context)=> HistoryScreen(),
        '/calendar': (context) => CalendarScreen(),
        '/profile':(context)=> ProfileScreen(),
        '/createEvent':(context) => CreateEventScreen(),
        '/search':(context) => SearchScreen()
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_eventfinder/model/userHistory.dart';
import '../../services/historyServices.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<UserHistory>> _events = {};
  List<UserHistory> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchUserEvents();
  }

  Future<void> _fetchUserEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    if (uid != null) {
      HistoryService historyService = HistoryService();
      List<UserHistory> userEvents = await historyService.fetchUserEvents(uid);

      Map<DateTime, List<UserHistory>> eventMap = {};
      for (var event in userEvents) {
        DateTime eventDate = event.date;

        if ((event.participantStatus == 'pending' || 
            event.participantStatus == 'Accepted') &&
            (event.status == 'Completed' || event.status == 'Upcoming' || event.status == 'Ongoing')) {
          DateTime eventDateOnly = DateTime(eventDate.year, eventDate.month, eventDate.day);
          if (!eventMap.containsKey(eventDateOnly)) {
            eventMap[eventDateOnly] = [];
          }
          eventMap[eventDateOnly]!.add(event);
        }
      }

      setState(() {
        _events = eventMap;
      });
    }
  }

  List<UserHistory> _getEventsForDay(DateTime day) {
    DateTime dayOnly = DateTime(day.year, day.month, day.day);
    return _events[dayOnly] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalender Acara'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // update `_focusedDay` here as well
                _selectedEvents = _getEventsForDay(selectedDay);
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(color: Color(0xFFCBED54)),
              weekendTextStyle: TextStyle(color: Color(0xFFCBED54)),
              selectedTextStyle: TextStyle(color: Colors.white),
              todayTextStyle: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _selectedEvents.isNotEmpty
                ? ListView.builder(
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      UserHistory event = _selectedEvents[index];
                      return ListTile(
                        title: Text(event.title),
                        subtitle: Text('${DateFormat('dd/MM/yyyy HH:mm').format(event.date)} - ${event.status}'),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'Tidak ada acara yang dipilih',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFFCBED54),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:new_eventfinder/config/config.dart';
import 'package:new_eventfinder/model/events.dart';
import 'package:new_eventfinder/services/eventservice.dart';
import 'package:new_eventfinder/ui/screens/detail_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  Future<List<Event>>? _searchResults;
  bool _isLoading = false;

  void _searchEvents(String query) {
    setState(() {
      _isLoading = true;
      _searchResults = EventService().searchEvents(query).then((results) {
        setState(() {
          _isLoading = false;
        });
        return results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       
      appBar: AppBar(
        title: Text('Search Events',style:TextStyle(color:Color(0xFFCBED54)),),
        backgroundColor: Color(0xFF30244D), 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: const Color(0xFFCBED54),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintStyle: TextStyle(color:Color(0xFFCBED54)),
                hintText: 'Search events...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search,),
                  onPressed: () {
                    _searchEvents(_searchController.text);
                  },
                ),
              ),
              onSubmitted: _searchEvents,
            ),
          ),
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else if (_searchResults != null)
            Expanded(
              child: FutureBuilder<List<Event>>(
                future: _searchResults,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No events found'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return EventCard(event: snapshot.data![index]);
                      },
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFF30244D),
      child: ListTile(
        title: Text(event.title,style:TextStyle(color:Color(0xFFCBED54))),
        subtitle: Text('${event.date}\nOrganizer: ${event.organizerType}\nCategory: ${event.category}',style:TextStyle(color:Color(0xFFCBED54))),
        leading: Image.network(Config.apiUrl + event.imageUrl),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
          );
        },
      ),
    );
  }
}

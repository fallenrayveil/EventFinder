import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:new_eventfinder/model/participant.dart';
import 'package:new_eventfinder/services/participantService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/eventService.dart';

class ParticipantListScreen extends StatefulWidget {
  final String eventId;

  ParticipantListScreen({required this.eventId});

  @override
  _ParticipantListScreenState createState() => _ParticipantListScreenState();
}

class _ParticipantListScreenState extends State<ParticipantListScreen> with SingleTickerProviderStateMixin {
  List<dynamic> participants = [];
  bool isLoading = true;
  bool isEventOwner = false;
  String currentUserId = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchCurrentUser();
    await _fetchParticipants();
    await _checkEventOwner();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('uid') ?? '';
    });
  }

  Future<void> _fetchParticipants() async {
    try {
      List<dynamic> fetchedParticipants = await ParticipantService.fetchParticipants(widget.eventId);
      setState(() {
        participants = fetchedParticipants;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkEventOwner() async {
    try {
      String eventOwnerId = await EventService.fetchEventOwnerId(widget.eventId);
      setState(() {
        isEventOwner = eventOwnerId == currentUserId;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateParticipantStatus(int index, String status) async {
    try {
      final participant = participants[index];
      await ParticipantService.updateParticipantStatus(participant.id, status);
      setState(() {
        participants[index] = Participant(
          id: participant.id,
          eventId: participant.eventId,
          uid: participant.uid,
          name: participant.name,
          email: participant.email,
          phone: participant.phone,
          status: status,
        );
      });
    } catch (error) {
      // Handle error
    }
  }

  void _acceptParticipant(int index) {
    _updateParticipantStatus(index, 'Accepted');
  }

  void _rejectParticipant(int index) {
    _updateParticipantStatus(index, 'Rejected');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> pendingParticipants = participants.where((p) => p.status == 'pending').toList();
    List<dynamic> acceptedParticipants = participants.where((p) => p.status == 'Accepted').toList();
    List<dynamic> rejectedParticipants = participants.where((p) => p.status == 'Rejected').toList();
    List<dynamic> cancelledParticipants = participants.where((p) => p.status == 'Cancelled').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Partisipan',style: TextStyle(color:Color(0xFFCBED54)  ) ,),
       backgroundColor: Color(0xFF30244D), 
        bottom: TabBar(
          labelColor:Color(0xFFCBED54)  ,
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending',),
            Tab(text: 'Accepted'),
            Tab(text: 'Rejected'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildParticipantList(pendingParticipants),
                _buildParticipantList(acceptedParticipants),
                _buildParticipantList(rejectedParticipants),
                _buildParticipantList(cancelledParticipants),
              ],
            ),
    );
  }

  Widget _buildParticipantList(List<dynamic> participants) {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        return Card(
          color: Color(0xFF30244D),  
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  participants[index].name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFCBED54)
                  ),
                ),
                SizedBox(height: 8.0),
                Text('Nomor Telepon: ${participants[index].phone}',style: TextStyle(color:Color(0xFFCBED54))),
                Text('Status: ${participants[index].status}',style: TextStyle(color:Color(0xFFCBED54))),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    if (isEventOwner)
                      ...[
                        ElevatedButton(
                          onPressed: () => _acceptParticipant(index),
                          child: Text('Acc'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () => _rejectParticipant(index),
                          child: Text('Reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ]
                    else
                      Text(
                        'Status: ${participants[index].status}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                           color: Color(0xFFCBED54)
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

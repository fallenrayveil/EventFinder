import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../model/participant.dart';

class ParticipantService {
  static Future<void> addParticipant({
    required String eventId,
    required String uid,
    required String email,
    required String name,
    required String phone,
  }) async {
    final url = Uri.parse('${Config.apiUrl}/events/$eventId/participants');
    final body = jsonEncode({
      'eventId': eventId,
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'status': 'pending', // or 'accepted', 'rejected', depending on your logic
    });

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      print('Participant added successfully');
    } else {
      throw Exception('Failed to add participant: ${response.body}');
    }
  }

  static Future<List<Participant>> fetchParticipants(String eventId) async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/events/$eventId/participants'));
    print(eventId);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((participant) => Participant.fromJson(participant)).toList();
    } else if(response.statusCode==404){
      return [];
    } else {
      throw Exception('Failed to load participants');
    }
  }

  static Future<void> updateParticipantStatus(String participantId, String status) async {
    final url = Uri.parse('${Config.apiUrl}/events/participants/$participantId/status');
    final body = jsonEncode({
      'status': status,
    });

    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      print('Participant status updated successfully');
    } else {
      throw Exception('Failed to update participant status: ${response.body}');
    }
  }

  static Future<void> removeParticipant(String eventId, String uid) async {
    final url = Uri.parse('${Config.apiUrl}/events/$eventId/participants/$uid');

    final response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      print('Participant removed successfully');
    } else {
      throw Exception('Failed to remove participant: ${response.body}');
    }
  }

 static Future<bool> isParticipant(String eventId, String uid) async {
  final response = await http.get(Uri.parse('${Config.apiUrl}/events/$eventId/participants'));
  print(response.body);
  if (response.statusCode == 200) {
    final List<dynamic> participants = jsonDecode(response.body);
    for (var participant in participants) {
      if (participant['uid'] == uid) {
        final String status = participant['status'];
        return status == 'Accepted' || status == 'pending';
      }
    }
    return false; // If the uid is not found in the list, return false
  } else if (response.statusCode == 404) {
    return false;
  } else {
    throw Exception('Failed to check participant status: ${response.body}');
  }
}
}

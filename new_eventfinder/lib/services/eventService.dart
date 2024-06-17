import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config.dart';
import '../model/events.dart';
import 'package:intl/intl.dart';

class EventService {
  
  Future<void> createEvent({
    required String title,
    required String description,
    required String date,
    required String capacity,
    required String mapsUrl,
    required String organizerType,
    required File? eventImage,
    required String category,
    required String location,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');

    if (uid == null) {
      throw Exception('User not logged in');
    }

    final uri = Uri.parse('${Config.apiUrl}/events');
    var request = http.MultipartRequest('POST', uri);

    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['date'] = date;
    request.fields['capacity'] = capacity;
    request.fields['mapsUrl'] = mapsUrl;
    request.fields['organizerType'] = organizerType;
    request.fields['category'] = category;
    request.fields['uid'] = uid;
    request.fields['location']=location;

    if (eventImage != null) {
      request.files.add(await http.MultipartFile.fromPath('eventImage', eventImage.path));
    }

    var response = await request.send();

    if (response.statusCode != 200) {
      var responseBody = await response.stream.bytesToString();
      throw Exception('Failed to save event: $responseBody');
    }
  }

  Future<List<Event>> fetchUserEvents(String uid) async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/events/user/$uid'));
    print(response.body);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((event) => Event.fromJson(event)).toList();
    } else {
      throw Exception('Failed to load events');
    }  
  }

  Future<List<Event>> fetchEvents() async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/events'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      print(jsonResponse); // Log the raw JSON response
      return jsonResponse.map((event) => Event.fromJson(event)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<void> updateEvent({
    required String eventId,
    required String title,
    required String description,
    required DateTime date,
    required String capacity,
    required String mapsUrl,
    required String organizerType,
    required String status,
    required String category, // Add rating
    required File? eventImage,
    required String location
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');

    if (uid == null) {
      throw Exception('User not logged in');
    }

    final uri = Uri.parse('${Config.apiUrl}/events/$eventId');
    var request = http.MultipartRequest('PUT', uri);

    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['date'] = DateFormat('dd/MM/yyyy HH:mm').format(date);
    request.fields['capacity'] = capacity;
    request.fields['mapsUrl'] = mapsUrl;
    request.fields['organizerType'] = organizerType;
    request.fields['status'] = status;
    request.fields['category'] = category;
    request.fields['location'] = location;
    request.fields['uid'] = uid;

    if (eventImage != null) {
      request.files.add(await http.MultipartFile.fromPath('eventImage', eventImage.path));
    }

    var response = await request.send();

    if (response.statusCode != 200) {
      var responseBody = await response.stream.bytesToString();
      throw Exception('Failed to update event: $responseBody');
    }
  }
  

  Future<void> deleteEvent(String eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');

    if (uid == null) {
      throw Exception('User not logged in');
    }

    final uri = Uri.parse('${Config.apiUrl}/events/$eventId');
    var response = await http.delete(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete event: ${response.body}');
    }
  }

  static Future<String> fetchEventOwnerId(String eventId) async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/events/$eventId/owner'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['uid'];
    } else {
      throw Exception('Failed to fetch event owner ID: ${response.body}');
    }
  }

  static Future<List<Event>> fetchEventByStatus(String status) async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/events/status/$status'));
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((event) => Event.fromJson(event)).toList();
    } else {
      throw Exception('Failed to load events by status');
    }
  }

  Future<List<Event>> searchEvents(String query) async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/searchEvents?search=$query'));
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((event) => Event.fromJson(event)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }
}

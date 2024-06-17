import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_eventfinder/model/userHistory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config.dart';


class HistoryService {
  Future<List<UserHistory>> fetchUserEvents(String uid) async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/events/participant/on/$uid'));
    print('wuhan kontol');
    print(response.body);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((event) => UserHistory.fromJson(event)).toList();
    } else {
      throw Exception('Failed to load events');
    }  
  }
}

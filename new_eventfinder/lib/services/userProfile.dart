import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../model/userProfille.dart';

class ProfileService {
  static Future<http.Response> saveProfileData({
    required String uid,
    required String name,
    required String phone,
    required String address,
    File? profileImage,
  }) async {
    var request = http.MultipartRequest('PUT', Uri.parse('${Config.apiUrl}/userProfile/$uid'));

    request.fields['name'] = name;
    request.fields['phone'] = phone;
    request.fields['address'] = address;

    if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath('profileImage', profileImage.path));
    }

    var response = await request.send();
    return await http.Response.fromStream(response);
  }

  static Future<UserProfile> fetchUserProfile(String uid) async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/userProfile/$uid'));

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

   static Future<String?> fetchUserName(String uid) async {
    try {
      UserProfile userProfile = await fetchUserProfile(uid);
      return userProfile.name;
    } catch (error) {
      print('Failed to fetch username: $error');
      return null;
    }
  }
}

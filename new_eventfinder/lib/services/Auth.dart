import 'dart:convert';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class AuthService {
  static Future<http.Response> register({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return response;
  }

  static Future<http.Response> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/login'), // Update with your server URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    return response;
  }

  Future<void> handleLoginResponse(
    Map<String, dynamic> userCredential, {
    required Function(String message, bool isError) updateNotification,
    required VoidCallback navigateToHome,
  }) async {
    if (userCredential.containsKey('error')) {
      updateNotification(userCredential['error'], true);
    } else {
      await saveUserCredential(userCredential);
      updateNotification('Login successful', false);
      navigateToHome();
    }
  }

  Future<void> saveUserCredential(Map<String, dynamic> userCredential) async {
    print(userCredential['UserSafeCredential']['uid']);
    final prefs = await SharedPreferences.getInstance();
    if (userCredential['UserSafeCredential'] != null && userCredential['UserSafeCredential']['uid'] != null) {
      prefs.setString('uid', userCredential['UserSafeCredential']['uid']);
      prefs.setString('accessToken', userCredential['UserSafeCredential']['accessToken']);
      prefs.setString('refreshToken', userCredential['UserSafeCredential']['refreshToken']);
      prefs.setString('email', userCredential['UserSafeCredential']['email']);
      prefs.setBool('emailVerified', userCredential['UserSafeCredential']['emailVerified']);
      prefs.setString('lastLoginAt', userCredential['UserSafeCredential']['lastLoginAt']);
      prefs.setString('createdAt', userCredential['UserSafeCredential']['createdAt']);
    } else {
      // Handle case when uid is null or user is null
    }
  }

}

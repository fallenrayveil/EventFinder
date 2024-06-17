import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/customTextBox1.dart';
import '../widgets/primaryButton.dart';
import '../../services/Auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _notificationMessage;
  Color? _notificationColor;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    final response = await AuthService.login(
      email: email,
      password: password,
    );

    final userCredential = jsonDecode(response.body);
    print(userCredential);
      await _authService.handleLoginResponse(
        userCredential,
        updateNotification: _updateNotification,

        navigateToHome: () async {
          
          Navigator.pushReplacementNamed(context, '/home');
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('uid', userCredential['userSafeCredential']['uid']);
        },
      );
    
  }

  void _updateNotification(String message, bool isError) {
    setState(() {
      _notificationMessage = message;
      _notificationColor = isError ? Colors.red : const Color(0xFFCBED54);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF30244D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: const Color(0xFFCBED54),
        ),
      ),
      backgroundColor: const Color(0xFF30244D),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCBED54),
                  fontFamily: 'Magra',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomTextBox1(
                placeholder: 'email',
                icon: Icons.person,
                controller: _emailController,
              ),
              const SizedBox(height: 20),
              CustomTextBox1(
                placeholder: 'Password',
                icon: Icons.lock,
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 20),
              if (_notificationMessage != null) ...[
                Text(
                  _notificationMessage!,
                  style: TextStyle(
                    color: _notificationColor,
                    fontSize: 16,
                    fontFamily: 'Magra',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
              PrimaryButton(
                text: 'Login',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _login();
                  }
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  'Create Account',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFCBED54),
                    decoration: TextDecoration.underline,
                    fontFamily: 'Magra',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Login with Google',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: 'Magra',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

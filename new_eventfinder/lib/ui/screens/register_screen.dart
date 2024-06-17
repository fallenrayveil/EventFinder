import 'dart:convert';
import 'package:flutter/material.dart';
import '../widgets/customTextBox1.dart';
import '../../services/Auth.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _notificationMessage;
  Color? _notificationColor;
  bool _isObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      setState(() {
        _notificationMessage = 'Passwords do not match';
        _notificationColor = Colors.red;
      });
      return;
    }

    final response = await AuthService.register(
      email: email,
      password: password,
    );

    if (response.statusCode == 201) {
      // Registration successful
      setState(() {
        _notificationMessage = 'Registration successful';
        _notificationColor = Color(0xFFCBED54); // Same color as "Create Account" text
      });
      Navigator.pop(context); // Navigate back to login screen
    } else {
      // Registration failed
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      setState(() {
        _notificationMessage = responseBody['error'] ?? 'Registration failed';
        _notificationColor = Colors.red;
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF30244D),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button press
            Navigator.pop(context);
          },
          color: Color(0xFFCBED54), // Warna tombol back
        ),
      ),
      backgroundColor: Color(0xFF30244D), // Warna latar belakang
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              SizedBox(height: 20),
              CustomTextBox1(
                placeholder: 'Email',
                icon: Icons.email,
                controller: _emailController,
                validator: _validateEmail,
              ),
              SizedBox(height: 20),
              CustomTextBox1(
                placeholder: 'Password',
                icon: Icons.lock,
                isPassword: true,
                controller: _passwordController,
                validator: _validatePassword,
              ),
              SizedBox(height: 20),
              CustomTextBox1(
                placeholder: 'Confirm Password',
                icon: Icons.lock_outline,
                isPassword: true,
                controller: _confirmPasswordController,
                validator: _validatePassword,
              ),
              SizedBox(height: 20),
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
                SizedBox(height: 20),
              ],
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _register();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Color(0xFFCBED54),
                ),
                child: Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Magra',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

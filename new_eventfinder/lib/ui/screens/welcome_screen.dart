import 'package:flutter/material.dart';
import '../widgets/primaryButton.dart'; // Pastikan mengimpor PrimaryButton di sini

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/welcome_image.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Title, slogan and login button
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
                children: <Widget>[
                  // Title
                  const Text(
                    'EventFinder',
                    style: TextStyle(
                      color: const Color(0xFFCBED54),
                      fontSize: 52.7,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Katibeh',
                      height: 1.0, // Mengatur tinggi baris
                    ),
                    textAlign: TextAlign.left, // Optional, but doesn't affect alignment in Column
                  ),
                  // Slogan
                  const Text(
                    'Find or create your dream event, Create Account/Sign in To Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.7,
                      fontFamily: 'Khand',
                      height: 1.2, // Mengatur tinggi baris untuk slogan
                    ),
                    textAlign: TextAlign.left, // Optional, but doesn't affect alignment in Column
                  ),
                  const SizedBox(height: 20),
                  // Row for aligning the button to the right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      PrimaryButton(
                        text: 'Login',
                        onPressed: () {
                          // Navigate to login screen
                          Navigator.pushNamed(context, '/login');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

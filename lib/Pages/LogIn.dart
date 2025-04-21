import 'package:flutter/material.dart';

class LogInPage extends StatelessWidget {
  const LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            Image.asset(
              'images/Background2.png',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
          ],
      ),
    );
  }
}
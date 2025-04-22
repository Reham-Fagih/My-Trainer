import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.png', // Need to chaang background
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 80),

                  Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 40,
                      color: Color(0xFF05262F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 20),

              Container(
                  // Email
                  width: 290,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: Color(0xFFD6D6D6),
                    ),
                  ),
              ),

                  SizedBox(height: 20),

              Container(
                  // Phone
                  width: 290,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Phone',
                      filled: true,
                      fillColor: Color(0xFFD6D6D6),
                    ),
                  ),
              ),

                  SizedBox(height: 20),

              Container(
                  // Password
                  width: 290,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: Color(0xFFD6D6D6),
                    ),
                  ),
              ),
                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF05262F),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Submit'),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
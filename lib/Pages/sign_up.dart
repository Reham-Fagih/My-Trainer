import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer'; 

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

Future<void> submitForm() async {
  String email = emailController.text.trim();
  String phone = phoneController.text.trim();
  String password = passwordController.text.trim();

  if (email.isEmpty || phone.isEmpty || password.isEmpty) {
    log("Please fill all fields");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill all fields')),
    );
    return;
  }

  final host = 'http://10.0.2.2:5000'; // emulator local address
  final url = Uri.parse('$host/signup');

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "phone": phone,
        "password": password,
      }),
    );

    log("Response status: ${response.statusCode}");
    log("Response body: ${response.body}");

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ ${responseBody['msg']}')),
      );
      // Optionally clear the form or navigate
      emailController.clear();
      phoneController.clear();
      passwordController.clear();
    } else {
      String errorMsg = responseBody['msg'] ?? responseBody['error'] ?? 'Something went wrong';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $errorMsg')),
      );
    }
  } catch (e) {
    log("Error during sign up: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/SignupBackground.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 80),

                    // Title
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 40,
                        color: Color(0xFF05262F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 20),

                    // Email
                    Container(
                      width: 290,
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          hintText: 'Email',
                          filled: true,
                          fillColor: Color(0xFFD6D6D6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Phone
                    Container(
                      width: 290,
                      child: TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.phone),
                          hintText: 'Phone',
                          filled: true,
                          fillColor: Color(0xFFD6D6D6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Password
                    Container(
                      width: 290,
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          hintText: 'Password',
                          filled: true,
                          fillColor: Color(0xFFD6D6D6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: submitForm,
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
          ),
        ],
      ),
    );
  }
}

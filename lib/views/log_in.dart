import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_first_project/services/forget_password.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'upload_screen.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _loading = false;

  Future<void> loginUser(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final host = "http://10.0.2.2:5000";
    final url = Uri.parse('$host/login');

    setState(() => _loading = true);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final token = responseBody['token'];
        final user = responseBody['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("authToken", token);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UploadScreen(
              baseUrl: host,
              userId: user["_id"],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/LoginBackground.jpg',
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
                    Icon(Icons.fitness_center, size: 60, color: Colors.white),
                    const SizedBox(height: 20),
                    const Text(
                      "Log in",
                      style: TextStyle(
                        fontSize: 40,
                        color: Color(0xFF05262F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
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
                    const SizedBox(height: 20),
                    SizedBox(
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
                    Align(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ForgotPasswordPage()),
                          );
                        },
                        child: Text(
                          "Forgot password?",
                          style:
                              TextStyle(color: Color(0xFF6BB0FF)), // Light Blue
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => loginUser(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF05262F),
                        foregroundColor: Colors.white,
                      ),
                      child: Text("Submit"),
                    ),
                    const SizedBox(height: 12),
/*
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0),
                            child: Divider(thickness: 1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("OR", style: TextStyle(color: Color(0xFF6BB0FF))),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0),
                            child: Divider(thickness: 1),
                          ),
                        ),
                      ],
                    ),


                    const SizedBox(height: 12),
                    */

/*
                    // Google Login Button To be removed??
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.g_mobiledata),
                      label: Text("Continue with Google"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Apple Login Button To be removed??
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.apple),
                      label: Text("Continue with Apple"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    */
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

import 'package:flutter/material.dart';
import 'package:flutter_first_project/Pages/forget_password.dart';

class LogInPage extends StatelessWidget {
  const LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // === Background Image ===
          Image.asset(
            'assets/images/LoginBackground.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),

          // === Main Content ===
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // === Logo Icon ===
                    Icon(Icons.fitness_center, size: 60, color: Colors.white),
                    const SizedBox(height: 20),

                    // === Login Title ===
                    const Text(
                      "Log in",
                      style: TextStyle(
                        fontSize: 40,
                        color: Color(0xFF05262F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // === Email Field ===
                    Container(
                      width: 290,
                      child: TextField(
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

                    // === Password Field ===
                    Container(
                      width: 290,
                      child: TextField(
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

                    // === Forgot Password Link ===
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ForgotPasswordPage()),
                          );
                        },
                        child: Text(
                          "Forgot password?",
                          style: TextStyle(color: Color(0xFF6BB0FF)), // Light Blue
                        ),
                      ),
                    ),

                    // === Submit Button ===
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF05262F),
                        foregroundColor: Colors.white,
                      ),
                      child: Text("Submit"),
                    ),
                    const SizedBox(height: 12),
// === OR Divider ===
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0), // Adjusted padding for shorter divider
                            child: Divider(thickness: 1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("OR", style: TextStyle(color: Color(0xFF6BB0FF))),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0), // Adjusted padding for shorter divider
                            child: Divider(thickness: 1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // === Google Login Button ===
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

                    // === Apple Login Button ===
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.apple),
                      label: Text("Continue with Apple"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    ),
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


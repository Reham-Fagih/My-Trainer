import 'package:flutter/material.dart';
import '../services/auth.dart'; // make sure this path matches your folder structure

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (!RegExp(r'^05\d{8}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Phone number must start with 05 and be 10 digits')),
      );
      return;
    }

    if (!RegExp(r'^[\w\.-]+@([\w\-]+\.)+[A-Za-z]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    final authService = AuthService();
    final result = await authService.register(email, phone, password);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));

    if (result.contains("✅")) {
      emailController.clear();
      phoneController.clear();
      passwordController.clear();
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
                    const SizedBox(height: 80),
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 40,
                        color: Color(0xFF05262F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildTextField(emailController, 'Email', Icons.email),
                    const SizedBox(height: 20),
                    buildTextField(phoneController, 'Phone', Icons.phone),
                    const SizedBox(height: 20),
                    buildTextField(passwordController, 'Password', Icons.lock,
                        obscure: true),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF05262F),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Submit'),
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

  Widget buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool obscure = false}) {
    return SizedBox(
      width: 290,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFD6D6D6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

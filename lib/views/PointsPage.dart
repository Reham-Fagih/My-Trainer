import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/config.dart';
import 'home.dart';

class PointsPage extends StatefulWidget {
  const PointsPage({super.key});

  @override
  State<PointsPage> createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
  int totalPoints = 0;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
  }

  // GET USER POINTS
  Future<void> _loadUserPoints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString("userEmail") ?? "";
      debugPrint("Loaded userEmail from prefs: '$userEmail'");

      if (userEmail.isEmpty) {
        setState(() {
          errorMessage = "No user email found in preferences.";
          isLoading = false;
        });
        return;
      }

      final uri = Uri.parse("$baseUrl/api/user/$userEmail");
      debugPrint("Fetching points for email: $userEmail at $uri");

      final response = await http.get(uri).timeout(const Duration(seconds: 20));
      debugPrint(
          "PointsPage response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          totalPoints = data["totalPoints"] ?? 0;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              "Failed to fetch: ${response.statusCode} ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/pointsPage.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(
                      child: Text(
                        "Error: $errorMessage",
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Your Points",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 60),
                    const SizedBox(height: 10),
                    Text(
                      "$totalPoints",
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF04383D),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Total Points",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF04383D),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Back to Home",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        // Back button
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
        ),
      ],
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class WorkoutPlanPage extends StatefulWidget {
  final String selectedEnvironment;
  final int selectedDuration;

  const WorkoutPlanPage({
    super.key,
    required this.selectedEnvironment,
    required this.selectedDuration,
  });

  @override
  State<WorkoutPlanPage> createState() => _WorkoutPlanPageState();
}

class _WorkoutPlanPageState extends State<WorkoutPlanPage> {
  Map<String, dynamic>? workoutPlan;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWorkoutPlan();
  }

  // Load Workout Plan from AI server
  Future<void> _loadWorkoutPlan() async {
    try {
      final uri = Uri.parse("http://10.0.2.2:5000/api/workoutplan");
      final body = jsonEncode({
        "environment": widget.selectedEnvironment,
        "duration": widget.selectedDuration,
      });

      final response = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        setState(() {
          workoutPlan = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed: ${response.statusCode} ${response.body}";
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

  // Save Workout Plan to MongoDB
  Future<void> saveWorkoutPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail') ?? "";
    final authToken = prefs.getString('authToken') ?? "";

    if (userEmail.isEmpty || workoutPlan == null) return;

    final uri = Uri.parse("http://10.0.2.2:5000/api/user/$userEmail/workout");

    try {
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode(workoutPlan),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Workout plan saved successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save plan: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/WorkoutpageBackground.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(child: Text("Error: $errorMessage"))
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final weeklyPlans = workoutPlan?["weeklyPlans"] ?? [];

    return Column(
      children: [
        // Home button
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Save Button
        ElevatedButton(
          onPressed: saveWorkoutPlan,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF04383D),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
          ),
          child: const Text(
            "Save Plan",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),

        const SizedBox(height: 10),

        // Workout Plan List
        Expanded(
          child: ListView.builder(
            itemCount: weeklyPlans.length,
            itemBuilder: (context, index) {
              final dayPlan = weeklyPlans[index];
              final exercises = dayPlan["exercises"] as List? ?? [];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ExpansionTile(
                  title: Text(
                    dayPlan["day"] ?? "Day",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  children: exercises.map<Widget>((exercise) {
                    final repsOrDuration = exercise["reps"] != null
                        ? 'Reps: ${exercise["reps"]}'
                        : 'Duration: ${exercise["duration"]}';

                    return ListTile(
                      title: Text(exercise["name"] ?? ""),
                      subtitle: Text(
                          'Sets: ${exercise["sets"] ?? "-"}, $repsOrDuration'),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

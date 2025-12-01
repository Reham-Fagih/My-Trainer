import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/config.dart';

import 'home.dart';

class WorkoutPlanPage extends StatefulWidget {
  final String selectedEnvironment;
  final int selectedDuration;
  final bool useExistingPlan; // when true, load latest plan from backend

  const WorkoutPlanPage({
    super.key,
    required this.selectedEnvironment,
    required this.selectedDuration,
    this.useExistingPlan = false,
  });

  @override
  State<WorkoutPlanPage> createState() => _WorkoutPlanPageState();
}

class _WorkoutPlanPageState extends State<WorkoutPlanPage> {
  Map<String, dynamic>? workoutPlan;
  bool isLoading = true;
  String? errorMessage;

  Map<String, bool> selectedExercises = {};

  // User metrics coming from profile/backend
  double? userWeight;
  double? userHeight;
  double? userBodyFat;

  @override
  void initState() {
    super.initState();
    if (widget.useExistingPlan) {
      _loadExistingWorkoutPlan();
    } else {
      _loadWorkoutPlan();
    }
  }

  // Load latest saved workout plan for this user from backend
  Future<void> _loadExistingWorkoutPlan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken') ?? '';
      final userEmail = prefs.getString('userEmail') ?? '';

      if (authToken.isEmpty || userEmail.isEmpty) {
        setState(() {
          errorMessage = "No user session found. Please log in again.";
          isLoading = false;
        });
        return;
      }

      final uri =
          Uri.parse('http://10.0.2.2:5000/api/user/$userEmail/workout/latest');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final latest = decoded['latestPlan'] as Map<String, dynamic>?;

        if (latest == null) {
          setState(() {
            errorMessage = 'No saved workout plan found.';
            isLoading = false;
          });
          return;
        }

        setState(() {
          workoutPlan = latest;
          final weeklyPlans = workoutPlan?["weeklyPlans"] ?? [];
          for (var dayPlan in weeklyPlans) {
            for (var ex in dayPlan["exercises"]) {
              selectedExercises[ex["name"]] = false;
            }
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load current workout plan: ${response.statusCode} ${response.body}';
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

  // Load Workout Plan from AI server
  Future<void> _loadWorkoutPlan() async {
    try {
      // Read token from SharedPreferences (set during login)
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken') ?? '';
      final userEmail = prefs.getString('userEmail');

      if (authToken.isEmpty || userEmail == null || userEmail.isEmpty) {
        setState(() {
          errorMessage = "No user session found. Please log in again.";
          isLoading = false;
        });
        return;
      }

      // Fetch user profile to get weight/height/bodyFat
      final userResponse = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/user/$userEmail'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (userResponse.statusCode != 200) {
        setState(() {
          errorMessage = 'Failed to load profile information.';
          isLoading = false;
        });
        return;
      }

      final userData = jsonDecode(userResponse.body) as Map<String, dynamic>;

      final double? weight = (userData['weight'] != null)
          ? double.tryParse(userData['weight'].toString())
          : null;
      final double? height = (userData['height'] != null)
          ? double.tryParse(userData['height'].toString())
          : null;

      double? bodyFat;
      if (userData['predictions'] != null &&
          (userData['predictions'] as List).isNotEmpty) {
        final lastPred =
            (userData['predictions'] as List).last as Map<String, dynamic>;
        bodyFat = double.tryParse(lastPred['value'].toString());
      }

      // Guard: require profile + body fat before requesting workout plan
      if (weight == null || height == null || bodyFat == null) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please complete your profile (weight, height) and body fat scan before generating a workout plan.',
            ),
          ),
        );

        Future.microtask(() {
          Navigator.pushNamed(context, '/ProfilePage');
        });
        return;
      }

      setState(() {
        userWeight = weight;
        userHeight = height;
        userBodyFat = bodyFat;
      });

      final uri = Uri.parse("http://10.0.2.2:5000/api/workoutplan");
      final body = jsonEncode({
        "environment": widget.selectedEnvironment,
        "duration": widget.selectedDuration,
        "weight": weight,
        "height": height,
        "bodyFat": bodyFat,
      });

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        setState(() {
          final decoded = jsonDecode(response.body);

          // API currently returns { message, savedPlan: { ...weeklyPlans... } }
          workoutPlan = decoded['savedPlan'] ?? decoded;

          final weeklyPlans = workoutPlan?["weeklyPlans"] ?? [];
          for (var dayPlan in weeklyPlans) {
            for (var ex in dayPlan["exercises"]) {
              selectedExercises[ex["name"]] = false;
            }
          }

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

  // Save Workout Plan to MongoDB sends only selected exercises
  Future<void> saveWorkoutPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail') ?? "";
    final authToken = prefs.getString('authToken') ?? "";

    if (userEmail.isEmpty || workoutPlan == null) return;

    final selected = selectedExercises.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toList();

    final uri = Uri.parse("http://10.0.2.2:5000/api/user/$userEmail/workout");

    try {
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode({
          "selectedExercises": selected,
          "fullPlan": workoutPlan,
        }),
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

  Future<void> _addPointsForExerciseToggle(bool checked) async {
    if (!checked) return; // only award points when checking, not unchecking

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        return; // no logged-in user; silently skip
      }

      final uri = Uri.parse('$baseUrl/user/$userId/points');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'points': 4,
        }),
      );

      // Optional: log non-success responses for debugging
      if (response.statusCode != 200) {
        // ignore: avoid_print
        print(
            'Failed to add points: \\${response.statusCode} \\${response.body}');
      }
    } catch (_) {
      // For now, ignore point update failures to avoid breaking UX.
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

        // Workout Plan List with CHECKBOXES
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
                    final name = exercise["name"];
                    final repsOrDuration = exercise["reps"] != null
                        ? 'Reps: ${exercise["reps"]}'
                        : 'Duration: ${exercise["duration"]}';

                    return CheckboxListTile(
                      title: Text(name ?? ""),
                      subtitle: Text(
                          'Sets: ${exercise["sets"] ?? "-"}, $repsOrDuration'),
                      value: selectedExercises[name] ?? false,
                      onChanged: (value) {
                        setState(() {
                          selectedExercises[name] = value!;
                        });
                        _addPointsForExerciseToggle(value ?? false);
                      },
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

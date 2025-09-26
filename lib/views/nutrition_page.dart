import 'package:flutter/material.dart';
import 'nutrition_goal.dart';

class ActivityLevelPage extends StatefulWidget {
  const ActivityLevelPage({super.key});

  @override
  State<ActivityLevelPage> createState() => _ActivityLevelPageState();
}

class _ActivityLevelPageState extends State<ActivityLevelPage> {
  String? selectedActivity;

  final List<String> activityLevels = [
    "Sedentary - Little or no exercise",
    "Light - Exercise 1-3 times/week",
    "Moderate - Exercise 4-5 times/week",
    "Active - Daily exercise or intense exercise 3-4 times/week",
    "Very Active - Intense exercise 6-7 times/week",
    "Extra Active - Very intense exercise daily, or physical job",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bgNutrition.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pushNamed(context, "/HomePage");
                  },
                ),
              ),

              const SizedBox(height: 40),

              // Title with shadow
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: const Text(
                  "Choose your activity level",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A4F53),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Dropdown with shadow
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 52, 147, 142),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedActivity,
                    items: activityLevels
                        .map(
                          (level) => DropdownMenuItem(
                            value: level,
                            child: Text(
                              level,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedActivity = value;
                      });
                      if (value != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NutritionGoalPage(
                              activityLevel: value,
                            ),
                          ),
                        );
                      }
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    dropdownColor: const Color.fromARGB(255, 48, 110, 128),
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

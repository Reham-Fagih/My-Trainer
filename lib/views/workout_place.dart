import 'package:flutter/material.dart';
import 'workout_plan.dart';

class WorkoutPlacePage extends StatelessWidget {
  final int selectedDuration;
  const WorkoutPlacePage({super.key, required this.selectedDuration});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/WorkoutpageBackground.png', fit: BoxFit.cover),
          ),
          Positioned(
            top: 150,
            left: 30,
            right: 30,
            child: const Center(
              child: Text(
                "Workout From",
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Color(0xFF004754)),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutPlanPage(
                        selectedEnvironment: 'home',
                        selectedDuration: selectedDuration,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 100),
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/Home.png"),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutPlanPage(
                        selectedEnvironment: 'gym',
                        selectedDuration: selectedDuration,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 250,
                  width: 350,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/GYM.png"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
// NOT FINISHED YET
class WorkoutPlanPage extends StatefulWidget {
  const WorkoutPlanPage({super.key});

  @override
  State<WorkoutPlanPage> createState() => _WorkoutPlanPageState();
}

class _WorkoutPlanPageState extends State<WorkoutPlanPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/WorkoutpageBackground.png',
              fit: BoxFit.cover,
            ),
          ),


          Positioned(
            top: 150,
            left: 30,
            right: 30,
            child: const Center(
              child: Text(
                "Here is your plan",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004754),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

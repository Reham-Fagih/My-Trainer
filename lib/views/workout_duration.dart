import 'package:flutter/material.dart';
import 'workout_place.dart';

class WorkoutDurationPage extends StatefulWidget {
  const WorkoutDurationPage({super.key});

  @override
  State<WorkoutDurationPage> createState() => _WorkoutDurationPageState();
}

class _WorkoutDurationPageState extends State<WorkoutDurationPage> {
  String selectedValue = "One Week";
  final List<String> durations = ["One Week", "Two Week", "Three Week", "Four Week"];

  int getDurationInNumber(String value) {
    switch (value) {
      case "One Week": return 1;
      case "Two Week": return 2;
      case "Three Week": return 3;
      case "Four Week": return 4;
      default: return 1;
    }
  }

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
                "Choose Duration",
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Color(0xFF004754)),
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: 30,
            right: 30,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal:35),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width:3),
                ),
                child: DropdownButton<String>(
                  value: selectedValue,
                  isExpanded: true,
                  dropdownColor: Colors.white.withOpacity(0.10),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: const TextStyle(color: Colors.white, fontSize: 25),
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    setState(() { selectedValue = newValue!; });
                  },
                  items: durations.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF04383D),
                  padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
                onPressed: () {
                  int durationNum = getDurationInNumber(selectedValue);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutPlacePage(selectedDuration: durationNum),
                    ),
                  );
                },


              ),

            ),
          ),
        ],
          /*
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: ElevatedButton(
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
          )
*/
      ),
    );
  }
}

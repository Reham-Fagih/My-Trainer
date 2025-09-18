import 'package:flutter/material.dart';
// NOT FINISHED YET
class WorkoutDurationPage extends StatefulWidget {
  const WorkoutDurationPage({super.key});

  @override
  State<WorkoutDurationPage> createState() => _WorkoutDurationPageState();
}

class _WorkoutDurationPageState extends State<WorkoutDurationPage> {

  String selectedValue = "One Week";


  final List<String> durations = [
    "One Week",
    "Two Week",
    "Three Week",
    "Four Week",

  ];
// here map the value of the list so it can be used for any calculations if needed (ckeck)

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
                "Choose Duration",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004754),
                ),
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
                  border: Border.all(color:  Colors.white, width:3),
                ),
                child: DropdownButton<String>(
                  value: selectedValue,
                  isExpanded: true,
                  dropdownColor:Colors.white.withOpacity(0.10),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue!;
                    });
                  },
                  items: durations.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
// NOT FINISHED YET
class WorkoutPlacePage extends StatelessWidget {
  const WorkoutPlacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

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
            child: Container(
              child: const Center(
                child: Text(
                  "Workout From",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004754),
                  ),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // send the selected to backend
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 100.0),
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
                  // send the selected to backend
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

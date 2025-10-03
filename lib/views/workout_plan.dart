import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/workout_plan_model.dart';

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
  WorkoutPlan? workoutPlan;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPlan();
  }

  Future<void> fetchPlan() async {
    final api = ApiService(baseUrl: 'http://10.0.2.2:5000');
// collect the data and set status
    try {
      final planJson = await api.fetchWorkoutPlan(
        environment: widget.selectedEnvironment,
        duration: widget.selectedDuration,
      );
      setState(() {
        workoutPlan = WorkoutPlan.fromJson(planJson);
        isLoading = false;
      });
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
            child: Center(
              child: Text(
                "Your Workout Plan",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004754),
                ),
              ),
            ),
          ),
          Positioned(
            top: 160,
            left: 30,
            right: 30,
            bottom: 80,
            child: Padding(
              padding: const EdgeInsets.all(16.0), // padding around content
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue, // spinner color
                ),
              )
                  : errorMessage != null
                  ? Center(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.builder(
                itemCount: workoutPlan?.weeklyPlans.length ?? 0,
                itemBuilder: (context, index) {
                  final dayPlan = workoutPlan!.weeklyPlans[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    child: ExpansionTile(
                      title: Text(
                        dayPlan.day,
                        style: const TextStyle(
                          color: Color(0xFF004754),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      children: dayPlan.exercises.map((exercise) {
                        final repsOrDuration = exercise.reps != null
                            ? 'Reps: ${exercise.reps}'
                            : 'Duration: ${exercise.duration}';
                        return ListTile(
                          title: Text(
                            exercise.name,
                            style: const TextStyle(
                              color: Colors.black, // exercise name color
                              fontSize: 16,        // exercise name size
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'Sets: ${exercise.sets}, $repsOrDuration',
                            style: const TextStyle(
                              color: Colors.grey,  // subtitle color
                              fontSize: 14,         // subtitle size
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),


          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.home, color: Colors.white, size: 45),
                onPressed: () {
                  Navigator.pushNamed(context, "/HomePage");
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
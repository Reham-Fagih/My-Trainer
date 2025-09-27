class WorkoutPlan {
  final int durationWeeks;
  final String environment;
  final List<DayPlan> weeklyPlans;

  WorkoutPlan({
    required this.durationWeeks,
    required this.environment,
    required this.weeklyPlans,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      durationWeeks: json['durationWeeks'],
      environment: json['environment'],
      weeklyPlans: (json['weeklyPlans'] as List)
          .map((e) => DayPlan.fromJson(e))
          .toList(),
    );
  }
}

class DayPlan {
  final String day;
  final List<Exercise> exercises;

  DayPlan({required this.day, required this.exercises});

  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      day: json['day'],
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
    );
  }
}

class Exercise {
  final String name;
  final int sets;
  final int? reps;
  final String? duration;

  Exercise({
    required this.name,
    required this.sets,
    this.reps,
    this.duration,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      sets: json['sets'],
      reps: json['reps'],
      duration: json['duration'],
    );
  }
}

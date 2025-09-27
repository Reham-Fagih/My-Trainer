import 'package:flutter/material.dart';
import 'views/workout_duration.dart';
import 'views/workout_place.dart';
import 'views/workout_plan.dart';
import 'views/welcome.dart';
import 'views/sign_up.dart';
import 'views/log_in.dart';
import 'views/profile.dart';
import 'views/home.dart';
import 'views/upload_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/welcome": (context) => const Welcome(),
        "/SignUpPage": (context) => const SignUpPage(),
        "/LogInPage": (context) => const LogInPage(),
        "/ProfilePage": (context) => const ProfilePage(),
        "/HomePage": (context) => const HomePage(),
        "/UploadPage": (context) => const UploadScreen(
          baseUrl: "http://10.0.2.2:5000",
          userId: "temp",
        ),
      },
      //    onGenerateRoute
      onGenerateRoute: (settings) {
        if (settings.name == '/WorkoutPlacePage') {
          final selectedDuration = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => WorkoutPlacePage(
              selectedDuration: selectedDuration,
            ),
          );
        } else if (settings.name == '/WorkoutPlanPage') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => WorkoutPlanPage(
              selectedEnvironment: args['environment'],
              selectedDuration: args['duration'],
            ),
          );
        }
        return null; // unknown route
      },
    );
  }
}

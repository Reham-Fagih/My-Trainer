import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/config.dart';
import 'views/home.dart';
import 'views/profile.dart';
import 'views/workout_duration.dart';
import 'views/workout_place.dart';
import 'views/log_in.dart';
import 'views/nutrition_goal.dart';
import 'views/nutrition_page.dart';
import 'views/welcome.dart';
import 'views/sign_up.dart';
import 'views/upload_screen.dart';
import 'views/workout_plan.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env').timeout(const Duration(seconds: 2));
    print('Loaded .env');
  } catch (_) {
    print('No .env found or load timed out — using defaults');
  }

  print('BASE_URL=${baseUrl}');

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
        "/": (context) => const Welcome(),
        "/nutrition": (context) => const ActivityLevelPage(),
        "/nutritionGoal": (context) => const NutritionGoalPage(
              activityLevel: '',
            ),
        "/WorkoutDurationPage": (context) => const WorkoutDurationPage(),
        "/welcome": (context) => const Welcome(), //Logout
        "/SignUpPage": (context) => const SignUpPage(),
        "/LogInPage": (context) => const LogInPage(),
        "/ProfilePage": (context) => const ProfilePage(),
        "/HomePage": (context) => HomePage(),
        "/UploadPage": (context) => const UploadScreen(
              baseUrl: '',
              userId: '',
            ),
      },
    );
  }
}

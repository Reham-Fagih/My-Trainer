import 'package:flutter/material.dart';
import 'views/log_in.dart';
import 'views/welcome.dart';
import 'views/sign_up.dart';
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
        "/": (context) => const Welcome(),
        "/SignUpPage": (context) => const SignUpPage(),
        "/LogInPage": (context) => const LogInPage(),
        "/UploadPage": (context) => const UploadScreen(
              baseUrl:
                  "http://10.0.2.2:5000", // adjust if your backend is different
              userId: "temp", // replace with real userId after login
            ),
      },
    );
  }
}

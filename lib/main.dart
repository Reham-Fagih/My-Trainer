import 'package:flutter/material.dart';//where is this?
import 'screens/log_in.dart';
import 'screens/welcome.dart';
import 'screens/sign_up.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => const Welcom(),
        "/SignUpPage": (context) => const SignUpPage(),
        "/LogInPage": (context) => const LogInPage(),

      },
    );
  }
}


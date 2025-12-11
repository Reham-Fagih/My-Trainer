import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(

        children: [
          Image.asset(
            'assets/images/welcome.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 90),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/LogInPage");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      "Log In",
                      style: TextStyle(color: Color(0xFF2A4F53), fontSize: 30),
                    ),
                  ),
                ),
                SizedBox(height: 60),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/SignUpPage");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 30,
                        color: Color(0xFF2A4F53),
                      ),
                    ),
                  ),
                ),

                // Continue as Guest temp
                SizedBox(height: 80),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Clear any logged-in user data when continuing as guest
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('authToken');
                      await prefs.remove('userId');
                      await prefs.remove('userEmail');

                      Navigator.pushNamed(context, "/HomePage");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.30),
                      padding: EdgeInsets.symmetric(vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      "Guest",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,


                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

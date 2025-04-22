import 'package:flutter/material.dart';


import 'package:flutter/material.dart';

class Welcom extends StatelessWidget {
  const Welcom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/images/welcome.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),

          // Centered buttons
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                      style: TextStyle(
                          color: Color(0xFF2A4F53),
                          fontSize: 30
                      ),

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
                        fontSize: 30 ,
                        color: Color(0xFF2A4F53),
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


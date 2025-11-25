import 'package:flutter/material.dart';

import '../views/nutrition_page.dart';
import '../views/workout_duration.dart';
import '../views/profile.dart';
import '../views/upload_screen.dart';
import '../views/leader_board.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/config.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/mainBackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    buildMenuItem(
                      context,
                      'Nutrition',
                      'assets/images/Nutrition.png',
                      ActivityLevelPage(),
                    ),
                    buildMenuItem(
                      context,
                      'Workout',
                      'assets/images/Workout.png',
                      WorkoutDurationPage(),
                    ),
                    buildMenuItem(
                      context,
                      'Leaderboard',
                      'assets/images/Leaderboard.png',
                      const LeaderBoardPage(),
                    ),
                    buildMenuItem(
                      context,
                      'Points',
                      'assets/images/Points.png',
                      const LeaderBoardPage(),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),

      // // nav bar
      // bottomNavigationBar: BottomAppBar(
      //   color: Colors.transparent,
      //   elevation: 0,
      //   child: Container(
      //     color: Colors.transparent,
      //     height: 60.0,
      //     padding: EdgeInsets.symmetric(horizontal: 30),
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: <Widget>[
      //         IconButton(
      //           icon: Image.asset('assets/images/Profileicon.png'),
      //           onPressed: () {
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(builder: (context) => ProfilePage()),
      //             );
      //           },
      //         ),
      //         IconButton(
      //           icon: Image.asset('assets/images/Homeicon.png'),
      //           onPressed: () {
      //             // Already in home
      //           },
      //         ),
      //         IconButton(
      //           icon: Image.asset('assets/images/Cameraicon.png'),
      //           onPressed: () {
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (context) => UploadScreen(
      //                   baseUrl: 'https://api.com', //temp
      //                   userId: 'temp',
      //                 ),
      //               ),
      //             );
      //           },
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      bottomNavigationBar: Container(
        height: 90,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/FooterBackground.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white, size: 45),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white, size: 45),
              onPressed: () {
                // Already in home
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () async {
                // Read the persisted userId from SharedPreferences so we don't
                // navigate with a hard-coded (invalid) id that causes Mongo cast
                // errors on the server.
                final prefs = await SharedPreferences.getInstance();
                final savedUserId = prefs.getString('userId') ?? '';

                if (savedUserId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please login to use this feature')),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white, size: 40),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Confirm Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Logout"),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('authToken');
                  Navigator.pushReplacementNamed(context, "/welcome");
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(
    BuildContext context,
    String label,
    String iconPath,
    Widget destinationPage,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage(iconPath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

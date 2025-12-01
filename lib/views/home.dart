import 'package:flutter/material.dart';
import 'nutrition_plan.dart';
import 'workout_plan.dart';
import 'nutrition_page.dart';
import 'workout_duration.dart';
import 'leader_board.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_footer.dart';
import 'PointsPage.dart';

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
                      onTap: () => showNutritionDialog(context),
                    ),
                    buildMenuItem(
                      context,
                      'Workout',
                      'assets/images/Workout.png',
                      onTap: () => showWorkoutDialog(context),
                    ),
                    buildMenuItem(
                      context,
                      'Leaderboard',
                      'assets/images/Leaderboard.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LeaderBoardPage()),
                        );
                      },
                    ),
                    buildMenuItem(
                      context,
                      'Points',
                      'assets/images/Points.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PointsPage()),
                        );
                      },
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
      bottomNavigationBar: const AppFooter(),
    );
  }

  void showNutritionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Nutrition Plan"),
        content:
            Text("Do you want a NEW nutrition plan or view your CURRENT plan?"),
        actions: [
          TextButton(
            child: Text("New Plan"),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ActivityLevelPage()));
            },
          ),
          TextButton(
            child: Text("Current Plan"),
            onPressed: () async {
              Navigator.pop(context);

              final prefs = await SharedPreferences.getInstance();
              final userId = prefs.getString('userId') ?? '';

              String savedActivity = '';
              String savedGoal = '';

              if (userId.isNotEmpty) {
                savedActivity =
                    prefs.getString('lastActivityLevel_$userId') ?? '';
                savedGoal = prefs.getString('lastGoal_$userId') ?? '';
              }

              // If there are no per-user values, block access to Current Plan
              if (savedActivity.isEmpty || savedGoal.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No previous nutrition plan settings found. Please create a new plan first.',
                    ),
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NutritionPlanPage(
                    activityLevel: savedActivity,
                    goal: savedGoal,
                    useExistingPlan: true,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void showWorkoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Workout Plan"),
        content:
            Text("Do you want a NEW workout plan or view your CURRENT plan?"),
        actions: [
          TextButton(
            child: Text("New Plan"),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => WorkoutDurationPage()));
            },
          ),
          TextButton(
            child: Text("Current Plan"),
            onPressed: () async {
              Navigator.pop(context);

              final prefs = await SharedPreferences.getInstance();
              final userId = prefs.getString('userId') ?? '';

              String selectedEnvironment = '';
              int selectedDuration = 0;

              if (userId.isNotEmpty) {
                selectedEnvironment =
                    prefs.getString('lastWorkoutEnvironment_$userId') ?? '';
                selectedDuration =
                    prefs.getInt('lastWorkoutDuration_$userId') ?? 0;
              }

              if (selectedEnvironment.isEmpty || selectedDuration <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No previous workout plan settings found. Please create a new plan first.',
                    ),
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkoutPlanPage(
                    selectedEnvironment: selectedEnvironment,
                    selectedDuration: selectedDuration,
                    useExistingPlan: true,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildMenuItem(
    BuildContext context,
    String label,
    String iconPath, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
          Text(label, style: TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }
}

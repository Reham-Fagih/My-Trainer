import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  Future<void> _handleLogout(BuildContext context) async {
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
      await prefs.remove('userEmail');
      Navigator.pushReplacementNamed(context, "/welcome");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Navigator.pushNamed(context, "/ProfilePage");
            },
          ),
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white, size: 45),
            onPressed: () {
              Navigator.pushNamed(context, "/HomePage");
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_rounded,
                color: Colors.white, size: 40),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final savedUserId = prefs.getString('userId') ?? '';

              if (savedUserId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please login to use this feature'),
                  ),
                );
                return;
              }

              // Use the existing named route from main.dart
              Navigator.pushNamed(context, "/UploadPage");
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 40),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }
}

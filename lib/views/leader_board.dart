import 'package:flutter/material.dart';

class LeaderBoardPage extends StatelessWidget {
  const LeaderBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          'Leader Board🏆'
              'comming soon',
          style: TextStyle(fontSize: 20, color: Colors.grey[700]),
        ),
      ),
    );
  }
}

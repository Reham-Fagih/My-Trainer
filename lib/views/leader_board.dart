import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/config.dart';
import 'home.dart';

class LeaderBoardPage extends StatefulWidget {
  const LeaderBoardPage({super.key});

  @override
  State<LeaderBoardPage> createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {
  List<Map<String, dynamic>> leaderboard = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    final uri = Uri.parse("$baseUrl/api/users/leaderboard?limit=50");

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          leaderboard = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/LeaderboardBackground.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                ),
              ),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : leaderboard.isEmpty
                      ? const Center(
                          child: Text(
                            "No leaderboard data",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        )
                      : _buildLeaderboard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboard() {
    final top3 =
        leaderboard.length >= 3 ? leaderboard.sublist(0, 3) : leaderboard;

    final rest = leaderboard.length > 3 ? leaderboard.sublist(3) : [];

    return Column(
      children: [
        const SizedBox(height: 70),
        SizedBox(
          height: 230,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 40,
                bottom: 30,
                child: _podiumCard(
                  rank: 2,
                  name: top3.length > 1
                      ? (top3[1]["name"] ?? top3[1]["email"])
                      : "-",
                ),
              ),

              Positioned(
                bottom: 60,
                child: _podiumCard(
                  rank: 1,
                  name: top3.isNotEmpty
                      ? (top3[0]["name"] ?? top3[0]["email"])
                      : "-",
                  big: true,
                ),
              ),

              // 3rd place
              Positioned(
                right: 40,
                bottom: 30,
                child: _podiumCard(
                  rank: 3,
                  name: top3.length > 2
                      ? (top3[2]["name"] ?? top3[2]["email"])
                      : "-",
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(22),
            ),
            child: ListView.builder(
              itemCount: rest.length,
              itemBuilder: (context, i) {
                final user = rest[i];

                final name =
                    user["name"] == null || user["name"].toString().trim() == ""
                        ? user["email"].toString().split("@")[0]
                        : user["name"];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      _circleAvatarBasic(),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Text(
                        "${user["totalPoints"]}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.star, color: Colors.amber, size: 26),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _podiumCard({
    required int rank,
    required String name,
    bool big = false,
  }) {
    Color color;
    if (rank == 1) {
      color = Colors.yellow.shade700;
    } else if (rank == 2) {
      color = Colors.grey.shade400;
    } else {
      color = Colors.brown.shade400;
    }

    return Column(
      children: [
        Text(
          "$rank",
          style: TextStyle(
            fontSize: big ? 36 : 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 5),
        CircleAvatar(
          radius: big ? 50 : 40,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.person,
            size: big ? 55 : 45,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _circleAvatarBasic() {
    return const CircleAvatar(
      radius: 24,
      backgroundColor: Colors.white,
      child: Icon(Icons.person, color: Colors.grey, size: 30),
    );
  }
}

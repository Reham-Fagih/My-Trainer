import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  bool isLoading = true;
  String? userEmail;
  String? authToken;

  double? bfPercent;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  // SharedPreferences
  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('userEmail');
    authToken = prefs.getString('authToken');

    if (userEmail != null && authToken != null) {
      fetchUserData();
    } else {
      setState(() => isLoading = false);
      print("⚠️ لم يتم العثور على بيانات المستخدم في SharedPreferences");
    }
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.get(
        // Use the same backend (Node server) port for both fetching and updating
        Uri.parse("http://10.0.2.2:5000/api/user/$userEmail"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          nameController.text = data["name"] ?? "";
          emailController.text = data["email"] ?? "";
          phoneController.text = data["phone"] ?? "";
          ageController.text = data["age"]?.toString() ?? "";
          weightController.text = data["weight"]?.toString() ?? "";
          heightController.text = data["height"]?.toString() ?? "";

          bfPercent = data["predictions"] != null &&
                  data["predictions"].isNotEmpty
              ? double.tryParse(data["predictions"].last["value"].toString())
              : null;

          isLoading = false;
        });
      } else {
        print("User not found: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> updateUserData() async {
    // Basic client-side validation
    final age = int.tryParse(ageController.text.trim());
    final weight = double.tryParse(weightController.text.trim());
    final height = double.tryParse(heightController.text.trim());

    if (age == null || age < 18 || age > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid age between 18 and 100 years."),
        ),
      );
      return;
    }

    // Simple reasonable ranges; you can tweak as needed
    if (weight == null || weight < 30 || weight > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Please enter a reasonable weight between 30 kg and 300 kg."),
        ),
      );
      return;
    }

    if (height == null || height < 100 || height > 250) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Please enter a reasonable height between 100 cm and 250 cm."),
        ),
      );
      return;
    }

    try {
      final response = await http.put(
        // Match the same backend base URL/port used in fetchUserData
        Uri.parse("http://10.0.2.2:5000/api/user/$userEmail"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
        body: json.encode({
          "name": nameController.text,
          // Email is read-only in the UI; don't send edited value back
          "email": emailController.text,
          "phone": phoneController.text,
          // Send numeric fields as numbers where possible for better type safety
          "age": age,
          "weight": weight,
          "height": height,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
        // Optionally refresh data from backend to ensure controllers reflect saved values
        await fetchUserData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update profile")),
        );
      }
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header Image
                  Container(
                    height: 200,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/Header.png"),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A555A),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: bfPercent == null
                                  ? Icon(Icons.percent,
                                      size: 40, color: Colors.grey[700])
                                  : Text(
                                      "${bfPercent!.toStringAsFixed(1)}%",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text("Edit Profile",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          _textField("Name", nameController),
                          _textField("Email", emailController),
                          _textField("Phone", phoneController),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _smallField("Age", ageController),
                              _smallField("Weight", weightController),
                              _smallField("Height", heightController),
                            ],
                          ),
                          const SizedBox(height: 25),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF04383D),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 12),
                              ),
                              onPressed: updateUserData,
                              child: const Text("Save",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
              onPressed: () {
                Navigator.pushNamed(context, "/UploadScreen");
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
                  await prefs.remove('userEmail');
                  Navigator.pushReplacementNamed(context, "/welcome");
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            readOnly: label == "Email", // Email field is not editable
            decoration: InputDecoration(
              filled: true,
              fillColor: label == "Email" ? Colors.grey[400] : Colors.grey[300],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 5),
        SizedBox(
          width: 80,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[300],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_first_project/views/results.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/prediction_controller.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/config.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedImage;
  bool _loading = false;
  double? _bfPercent; // stores the predicted body fat percentage

  final picker = ImagePicker();
  late PredictionController controller;
  String? _userId;

  @override
  void initState() {
    super.initState();
    controller = PredictionController(apiService: ApiService(baseUrl: baseUrl));
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId') ?? '';
    });
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _bfPercent = null; // reset previous prediction
      });
    }
  }

  Future<void> uploadAndPredict() async {
    if (_selectedImage == null) return;
    setState(() => _loading = true);

    try {
      if (_userId == null || _userId!.isEmpty) {
        throw Exception('Missing userId — please login again');
      }

      final response =
          await controller.predictFromImage(_selectedImage!, _userId!);

      setState(() {
        _bfPercent = response.bfPercent;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsPage(
            bodyFatPercentage: _bfPercent!,
            imagePath: _selectedImage!.path,
          ),
        ),
      );
    } catch (e) {
      final text = e.toString().replaceFirst('Exception: ', '');
      // Log to verify we're catching the error and see the exact message
      // from the backend (useful during debugging).
      // ignore: avoid_print
      print('Upload error: $text');

      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger != null) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(text)));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Image Header (fixed height)
          SizedBox(
            height: 120,
            width: double.infinity,
            child: Image.asset(
              "assets/images/Header.png",
              fit: BoxFit.fill,
              alignment: Alignment.topCenter,
            ),
          ),

          // Content area: center the two boxes vertically between header and footer
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Take Picture Button
                    GestureDetector(
                      onTap: () => pickImage(ImageSource.camera),
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 8.0),
                          height: 200,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image:
                                  AssetImage("assets/images/TakePicButton.png"),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Pick from Gallery Button
                    GestureDetector(
                      onTap: () => pickImage(ImageSource.gallery),
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 16.0),
                          height: 200,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image:
                                  AssetImage("assets/images/UploudButton.png"),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Upload & Predict Button
                    if (_selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                          ),
                          icon: _loading
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.cloud_upload,
                                  color: Colors.white,
                                  size: 30,
                                ),
                          label: Text(
                            _loading ? "Uploading" : "Predict",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: _loading ? null : uploadAndPredict,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // ---------------- Footer ----------------
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
                }),
            IconButton(
                icon: const Icon(Icons.home, color: Colors.white, size: 45),
                onPressed: () {
                  Navigator.pushNamed(context, "/HomePage");
                }),
            IconButton(
                icon: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 40),
                onPressed: () {
                  Navigator.pushNamed(context, "/UploadPage");
                }),
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
}

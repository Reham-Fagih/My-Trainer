import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/prediction_controller.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadScreen extends StatefulWidget {
  final String baseUrl;
  final String userId;

  const UploadScreen({super.key, required this.baseUrl, required this.userId});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedImage;
  bool _loading = false;
  double? _bfPercent; // stores the predicted body fat percentage

  final picker = ImagePicker();
  late PredictionController controller;

  @override
  void initState() {
    super.initState();
    controller =
        PredictionController(apiService: ApiService(baseUrl: widget.baseUrl));
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
      final response =
          await controller.predictFromImage(_selectedImage!, widget.userId);

      setState(() {
        _bfPercent = response.bfPercent;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Header
            Container(
              height: 200,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/Header.png"),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Take Picture Button
            GestureDetector(
              onTap: () => pickImage(ImageSource.camera),
              child: Container(
                margin: const EdgeInsets.only(top: 45.0),
                height: 200,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/TakePicButton.png"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Pick from Gallery Button
            GestureDetector(
              onTap: () => pickImage(ImageSource.gallery),
              child: Container(
                margin: const EdgeInsets.only(top: 30.0),
                height: 200,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/UploudButton.png"),
                    fit: BoxFit.contain,
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
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
                    : const Icon(Icons.cloud_upload,color: Colors.white,size: 30,),

                label: Text(

                  _loading ? "Uploading" : "Predict",
                  style: const TextStyle(
                    fontSize:20,
                    color: Colors.white,

                  ),
                ),
                onPressed: _loading ? null : uploadAndPredict,
              ),
            ),
          ],
        ),
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
                  Navigator.pushNamed(context, "/");
                }),
            IconButton(
                icon: const Icon(Icons.home, color: Colors.white, size: 45),
                onPressed: () {
                  Navigator.pushNamed(context, "/");
                }),
            IconButton(
                icon: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 40),
                onPressed: () {
                  Navigator.pushNamed(context, "/");
                }),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white, size: 40),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('authToken');
                Navigator.pushReplacementNamed(context, "/welcome");
              },
            ),
          ],
        ),
      ),
    );
  }
}

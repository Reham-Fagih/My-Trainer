import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/prediction_controller.dart';
import '../services/api_service.dart';

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
// ---------------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Image Header
          Container(
            height: 200,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/Header.png"), // <-- header image
                fit: BoxFit.contain,

              ),
            ),
          ),

          // Body
          GestureDetector(
            onTap: () => pickImage(ImageSource.camera),
            child: Container(
              margin: const EdgeInsets.only(top: 20.0),
              height: 200,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/TakePicButton.png"),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),


          GestureDetector(
            onTap: () => pickImage(ImageSource.gallery),
            child: Container(
              margin: const EdgeInsets.only(top: 25.0),
              height: 200,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/UploudButton.png"),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),



          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: _loading
                        ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.cloud_upload),
                    label: const Text("Predict"),
                    onPressed: _loading ? null : uploadAndPredict,
                  ),
                  const SizedBox(height: 20),
                  /* In result page
                  if (_bfPercent != null)
                    Text(
                      "Estimated Body Fat: ${_bfPercent!.toStringAsFixed(2)}%",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ), */
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
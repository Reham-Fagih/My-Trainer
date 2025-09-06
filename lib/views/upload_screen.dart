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

  Future<void> pickImage() async {
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _bfPercent = null;
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
      appBar: AppBar(title: const Text("Upload Image")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 200)
                : Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: Text("No image selected")),
                  ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo),
              label: const Text("Pick Image"),
              onPressed: pickImage,
            ),
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
              label: const Text("Upload & Predict"),
              onPressed: _loading ? null : uploadAndPredict,
            ),
            const SizedBox(height: 20),
            if (_bfPercent != null)
              Text(
                "Estimated Body Fat: ${_bfPercent!.toStringAsFixed(2)}%",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}

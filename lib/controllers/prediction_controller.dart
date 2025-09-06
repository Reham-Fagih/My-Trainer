import 'dart:io';
import '../models/prediction.dart';
import '../services/api_service.dart';

class PredictionController {
  final ApiService apiService;

  PredictionController({required this.apiService});

  Future<Prediction> predictFromImage(File image, String userId) async {
    final data = await apiService.uploadImageForPrediction(image, userId);
    return Prediction.fromJson(data);
  }
}

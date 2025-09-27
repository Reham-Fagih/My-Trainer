import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Upload image for prediction (existing)
  Future<Map<String, dynamic>> uploadImageForPrediction(
      File imageFile, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final uri = Uri.parse('$baseUrl/predict');
    final request = http.MultipartRequest('POST', uri);

    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));
    request.fields['userId'] = userId;

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Prediction failed: ${response.statusCode} ${response.body}');
    }
  }

  // Fetch workout plan
  Future<Map<String, dynamic>> fetchWorkoutPlan({
    required String environment,
    required int duration,
    int weight = 75,
    int height = 180,
    int bodyFat = 18,
  }) async {
    final uri = Uri.parse('$baseUrl/api/workoutplan');
    final body = jsonEncode({
      'environment': environment,
      'duration': duration,
      'weight': weight,
      'height': height,
      'bodyFat': bodyFat,
    });

    try {
      final response = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to fetch workout plan: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching workout plan: $e');
    }
  }
}

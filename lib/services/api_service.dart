import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

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
}

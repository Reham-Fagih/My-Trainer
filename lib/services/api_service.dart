import 'dart:convert';
import 'dart:io';
import 'dart:async';
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

    try {
      // Send the multipart request and apply a timeout so the UI doesn't hang
      // indefinitely if the server or ML service is slow or unreachable.
      final streamed =
          await request.send().timeout(const Duration(seconds: 60));

      final response = await http.Response.fromStream(streamed).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        // Helpful error for missing/invalid token
        throw Exception('Unauthorized (401): ${response.body}');
      } else {
        throw Exception(
            'Prediction failed: ${response.statusCode} ${response.body}');
      }
    } on TimeoutException catch (_) {
      throw Exception(
          'Request timed out. The server may be busy or unreachable.');
    } on SocketException catch (e) {
      throw Exception('Network error while uploading image: ${e.message}');
    } catch (e) {
      rethrow;
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

  // Add points to a user
  Future<Map<String, dynamic>> addUserPoints({
    required String userId,
    required int points,
  }) async {
    final uri = Uri.parse('$baseUrl/user/$userId/points');

    final body = jsonEncode({
      'points': points,
    });

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to add points: ${response.statusCode} ${response.body}',
        );
      }
    } on TimeoutException catch (_) {
      throw Exception('Request timed out while adding points.');
    } on SocketException catch (e) {
      throw Exception('Network error while adding points: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while adding points: $e');
    }
  }
// how to call points:

  // Future<void> giveUserPoints(String userId) async {
  //   try {
  //     // e.g. add 50 points
  //     final updatedUser =
  //         await apiService.addUserPoints(userId: userId, points: 50);

  //     final newTotal = updatedUser['totalPoints'];
  //     print('New total points: $newTotal');
  //   } catch (e) {
  //     print('Error adding points: $e');
  //   }
  // }
}

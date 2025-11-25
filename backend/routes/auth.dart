import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  /// Use the shared `baseUrl` from `lib/services/config.dart` so devs can
  /// override it with `.env` per-machine.

  Future<String> register(String email, String phone, String password) async {
    final url = Uri.parse('$baseUrl/signup');
    final body = jsonEncode({
      "email": email,
      "phone": phone,
      "password": password,
    });

    try {
      // Debug: print the URL being requested so we can confirm the endpoint.
      // ignore: avoid_print
      print('AuthService.register POST $url');
      final response = await http
          .post(url, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 7));

      // Try to decode JSON safely.
      String msg;
      try {
        final data = jsonDecode(response.body);
        if (response.statusCode == 201) {
          msg = data['msg'] ?? 'Signup successful';

          // After a successful signup, attempt to log the user in automatically
          // so we receive and persist a JWT for protected endpoints.
          final loginResult = await login(email, password);
          // If loginResult indicates success (starts with ✅) return combined message.
          if (loginResult.startsWith('✅')) {
            return '✅ $msg - Logged in';
          }

          // Login failed, but signup succeeded.
          return '✅ $msg - Login not completed: ${loginResult.replaceFirst('❌ ', '')}';
        } else {
          msg = data['msg'] ?? data['error'] ?? response.body;
          return '❌ $msg';
        }
      } catch (_) {
        // Non-JSON response -- return raw body or status.
        if (response.statusCode == 201) {
          return '✅ ${response.body.isNotEmpty ? response.body : 'Signup successful'}';
        }
        return '❌ ${response.body.isNotEmpty ? response.body : 'Signup failed (status ${response.statusCode})'}';
      }
    } on TimeoutException {
      return '❌ Error: request timed out';
    } on SocketException catch (e) {
      return '❌ Network error: ${e.message}';
    } catch (e) {
      return '❌ Error: $e';
    }
  }

  Future<String> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final body = jsonEncode({"email": email, "password": password});

    try {
      final response = await http
          .post(url, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 7));

      try {
        final data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          final token = data['token'];
          if (token != null && token is String && token.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('authToken', token);
            // Optionally save user info
            if (data['user'] != null && data['user']['_id'] != null) {
              await prefs.setString('userId', data['user']['_id'].toString());
            }
          }
          return '✅ ${data['message'] ?? 'Login successful'}';
        } else {
          return '❌ ${data['message'] ?? data['error'] ?? response.body}';
        }
      } catch (_) {
        if (response.statusCode == 200) {
          return '✅ ${response.body.isNotEmpty ? response.body : 'Login successful'}';
        }
        return '❌ ${response.body.isNotEmpty ? response.body : 'Login failed (status ${response.statusCode})'}';
      }
    } on TimeoutException {
      return '❌ Error: request timed out';
    } on SocketException catch (e) {
      return '❌ Network error: ${e.message}';
    } catch (e) {
      return '❌ Error: $e';
    }
  }
}

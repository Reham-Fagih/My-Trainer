import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://172.20.10.2:5000'; // For google chrome

  Future<String> register(String email, String phone, String password) async {
    final url = Uri.parse('$baseUrl/signup');
    final body = jsonEncode({
      "email": email,
      "phone": phone,
      "password": password,
    });

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'}, body: body);

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return "✅ ${data['msg']}";
      } else {
        return "❌ ${data['msg'] ?? data['error']}";
      }
    } catch (e) {
      return "❌ Error: $e";
    }
  }

  Future<String> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final body = jsonEncode({"email": email, "password": password});

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'}, body: body);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return "✅ ${data['message']}";
      } else {
        return "❌ ${data['message'] ?? data['error']}";
      }
    } catch (e) {
      return "❌ Error: $e";
    }
  }
}

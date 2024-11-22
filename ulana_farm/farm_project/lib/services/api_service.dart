import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  static Future<Map<String, dynamic>> registerUser(
      String username,
      String email,
      String password,
      String confirmPassword,
      String role) async {
    final url = Uri.parse('$baseUrl/register/');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
        "confirm_password": confirmPassword,
        "role": role,
      }),
    );

    if (response.statusCode == 201) {
      return {"success": true, "message": "Registration successful!"};
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)['error'] ?? "Registration failed"
      };
    }
  }

  static Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    final url = Uri.parse('$baseUrl/login/');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {"success": true, "message": "Login successful!", "data": data};
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)['error'] ?? "Login failed"
      };
    }
  }
}

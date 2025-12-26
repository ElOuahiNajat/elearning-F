import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8080/api/auth';
  static const String tokenKey = 'accessToken';

  static Future<AuthResponse?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(LoginRequest(email: email, password: password).toJson()),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        await _saveToken(authResponse.accessToken);
        return authResponse;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  // Helper to get auth headers
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<String?> getUserRole() async {
    final token = await getToken();
    if (token == null) return null;
    
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = parts[1];
      // Utiliser base64Url car c'est le standard JWT
      final String decoded = utf8.decode(base64Url.decode(base64Url.normalize(payload)));
      final Map<String, dynamic> data = jsonDecode(decoded);
      
      print('JWT Payload: $data');
      
      final roleData = data['role'];
      String? role;
      if (roleData is List) {
        role = roleData.isNotEmpty ? roleData[0].toString() : null;
      } else {
        role = roleData?.toString();
      }
      
      print('Detected Role: $role');
      return role;
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }
}

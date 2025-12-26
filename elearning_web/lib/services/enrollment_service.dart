import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/enrollment.dart';
import 'auth_service.dart';

class EnrollmentService {
  static const String baseUrl = 'http://localhost:8080/api/enrollments';

  static Future<Enrollment> enroll(int courseId, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/course/$courseId/user/$userId'),
      headers: await AuthService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return Enrollment.fromJson(json.decode(response.body));
    }
    throw Exception('Erreur d\'inscription: ${response.statusCode} - ${response.body}');
  }

  static Future<List<Enrollment>> getUserEnrollments(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId'),
      headers: await AuthService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Enrollment.fromJson(e)).toList();
    }
    throw Exception('Erreur récupération inscriptions: ${response.statusCode}');
  }

  static Future<List<Enrollment>> getCourseEnrollments(int courseId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/course/$courseId'),
      headers: await AuthService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Enrollment.fromJson(e)).toList();
    }
    throw Exception('Erreur récupération inscrits: ${response.statusCode}');
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';
import 'auth_service.dart';

class RecommendationService {
  static const String baseUrl = 'http://localhost:8080/api/recommendations';

  static Future<List<Course>> getRecommendedCourses(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'), headers: await AuthService.getAuthHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Course.fromJson(e)).toList();
    }
    throw Exception('Erreur récupération recommandations: ${response.statusCode}');
  }
}

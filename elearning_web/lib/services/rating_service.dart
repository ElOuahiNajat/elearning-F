import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rating.dart';
import 'auth_service.dart';

class RatingService {
  static const String baseUrl = 'http://localhost:8080/api/ratings';

  static Future<Rating> addRating(RatingRequest request) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Rating.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add rating: ${response.body}');
    }
  }

  static Future<List<Rating>> getRatingsByCourse(int courseId) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/course/$courseId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Rating.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load ratings: ${response.body}');
    }
  }
}

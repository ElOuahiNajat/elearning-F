import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';
import 'auth_service.dart';

class CourseService {
  static const String baseUrl = "http://localhost:8080/api/courses";

  static Future<List<Course>> getCourses() async {
    final response = await http.get(Uri.parse(baseUrl), headers: await AuthService.getAuthHeaders());
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => Course.fromJson(e)).toList();
    }
    throw Exception("Erreur chargement cours");
  }

  static Future<void> deleteCourse(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: await AuthService.getAuthHeaders());
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Erreur suppression');
    }
  }

  static Future<void> updateCourse(int id, Course course) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: await AuthService.getAuthHeaders(),
      body: json.encode(course.toJson()),
    );
    if (response.statusCode != 200) throw Exception('Erreur modification');
  }

  static Future<Course> createCourse(Course course) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await AuthService.getAuthHeaders(),
      body: json.encode(course.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Course.fromJson(json.decode(response.body));
    }
    throw Exception('Erreur création cours');
  }

  static Future<List<Course>> searchCourses(String title) async {
    final uri = Uri.parse('$baseUrl/search?title=${Uri.encodeQueryComponent(title)}');
    final response = await http.get(uri, headers: await AuthService.getAuthHeaders());
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => Course.fromJson(e)).toList();
    }
    throw Exception('Erreur recherche cours');
  }

  static Future<int> getTotalCourses() async {
    final res = await http.get(Uri.parse('$baseUrl/dashboard/total'), headers: await AuthService.getAuthHeaders());
    if (res.statusCode == 200) return int.parse(res.body);
    throw Exception('Erreur total cours');
  }

  static Future<List<Course>> getLatestCourses({int limit = 5}) async {
    final res = await http.get(Uri.parse('$baseUrl/dashboard/latest?limit=$limit'), headers: await AuthService.getAuthHeaders());
    if (res.statusCode == 200) {
      List data = json.decode(res.body);
      return data.map((e) => Course.fromJson(e)).toList();
    }
    throw Exception('Erreur derniers cours');
  }

  static Future<List<Course>> getCoursesWithMostChapters({int limit = 5}) async {
    final res = await http.get(Uri.parse('$baseUrl/dashboard/most-chapters?limit=$limit'), headers: await AuthService.getAuthHeaders());
    if (res.statusCode == 200) {
      List data = json.decode(res.body);
      return data.map((e) => Course.fromJson(e)).toList();
    }
    throw Exception('Erreur cours populaires');
  }
}

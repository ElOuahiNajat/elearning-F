import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'auth_service.dart';

class UsersPageResult {
  final List<User> content;
  final int totalPages;
  final int number;
  final int size;
  final int totalElements;
  UsersPageResult({required this.content, required this.totalPages, required this.number, required this.size, required this.totalElements});
  factory UsersPageResult.fromJson(Map<String, dynamic> json) {
    final data = (json['content'] as List<dynamic>?) ?? [];
    return UsersPageResult(
      content: data.map((e) => User.fromJson(e as Map<String, dynamic>)).toList(),
      totalPages: json['totalPages'] ?? 0,
      number: json['number'] ?? 0,
      size: json['size'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
    );
  }
}

class UserService {
  static const String baseUrl = 'http://localhost:8080/api/users';

  static Future<UsersPageResult> getUsers({int page = 0, int size = 5}) async {
    final res = await http.get(Uri.parse('$baseUrl?page=$page&size=$size'), headers: await AuthService.getAuthHeaders());
    if (res.statusCode == 200) return UsersPageResult.fromJson(json.decode(res.body));
    throw Exception('Failed to load users');
  }

  static Future<User> getById(String id) async {
    final res = await http.get(Uri.parse('$baseUrl/$id'), headers: await AuthService.getAuthHeaders());
    if (res.statusCode == 200) return User.fromJson(json.decode(res.body));
    throw Exception('Failed to get user');
  }

  static Future<void> createUser(User user, {String? password}) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: await AuthService.getAuthHeaders(),
      body: json.encode(user.toJson(password: password)),
    );
    if (res.statusCode != 201 && res.statusCode != 200) throw Exception('Failed to create user');
  }

  static Future<User> updateUser(String id, User user, {String? password}) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: await AuthService.getAuthHeaders(),
      body: json.encode(user.toJson(password: password)),
    );
    if (res.statusCode == 200) return User.fromJson(json.decode(res.body));
    throw Exception('Failed to update user');
  }

  static Future<void> deleteUser(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'), headers: await AuthService.getAuthHeaders());
    if (res.statusCode != 204 && res.statusCode != 200) throw Exception('Failed to delete user');
  }

  static Future<Uint8List> exportCsv() async {
    final res = await http.get(Uri.parse('$baseUrl/export/csv'), headers: await AuthService.getAuthHeaders());
    if (res.statusCode == 200) return res.bodyBytes;
    throw Exception('Failed to export CSV');
  }

  static Future<int> getTotalUsers() async {
    final res = await http.get(Uri.parse('$baseUrl/dashboard/total'), headers: await AuthService.getAuthHeaders());
    if (res.statusCode == 200) return int.parse(res.body);
    throw Exception('Failed to get total users');
  }

  static Future<Map<String, int>> getUserCountByRole() async {
    final res = await http.get(Uri.parse('$baseUrl/dashboard/by-role'), headers: await AuthService.getAuthHeaders());
    if (res.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(res.body);
      return data.map((key, value) => MapEntry(key, value as int));
    }
    throw Exception('Failed to get user stats');
  }

  static Future<List<User>> getLatestUsers({int limit = 5}) async {
    final res = await http.get(Uri.parse('$baseUrl/dashboard/latest?limit=$limit'), headers: await AuthService.getAuthHeaders());
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => User.fromJson(e)).toList();
    }
    throw Exception('Failed to get latest users');
  }
}

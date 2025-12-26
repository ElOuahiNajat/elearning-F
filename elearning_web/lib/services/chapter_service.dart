import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import '../models/chapter.dart';
import 'auth_service.dart';

class ChapterService {
  // backend base for courses
  static const String baseCoursesUrl = 'http://localhost:8080/api/courses';

  static Future<List<Chapter>> getChaptersByCourse(int courseId) async {
    final res = await http.get(Uri.parse('$baseCoursesUrl/$courseId/chapters'), headers: await AuthService.getAuthHeaders());
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List<dynamic>;
      return data.map((e) => Chapter.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load chapters (${res.statusCode}): ${res.body}');
  }

  static Future<Chapter> getChapter(int courseId, int id) async {
    final res = await http.get(Uri.parse('$baseCoursesUrl/$courseId/chapters/$id'), headers: await AuthService.getAuthHeaders());
    if (res.statusCode == 200) {
      return Chapter.fromJson(json.decode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to get chapter: ${res.statusCode}');
  }

  static Future<Chapter> createChapter(int courseId, Chapter chapter, {PlatformFile? videoFile, PlatformFile? pdfFile}) async {
    final uri = Uri.parse('$baseCoursesUrl/$courseId/chapters');
    final request = http.MultipartRequest('POST', uri);
    
    request.headers.addAll(await AuthService.getAuthHeaders());
    
    request.fields['title'] = chapter.title;
    if (chapter.description != null) request.fields['description'] = chapter.description!;
    if (chapter.orderNumber != null) request.fields['orderNumber'] = chapter.orderNumber.toString();

    if (videoFile != null && videoFile.bytes != null) {
      final contentType = MediaType('video', videoFile.extension ?? 'mp4');
      request.files.add(http.MultipartFile.fromBytes('video', videoFile.bytes!, filename: videoFile.name, contentType: contentType));
    }

    if (pdfFile != null && pdfFile.bytes != null) {
      final contentType = MediaType('application', 'pdf');
      request.files.add(http.MultipartFile.fromBytes('pdf', pdfFile.bytes!, filename: pdfFile.name, contentType: contentType));
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Chapter.fromJson(json.decode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to create chapter: ${res.statusCode} ${res.body}');
  }

  static Future<Chapter> updateChapter(int courseId, int chapterId, Chapter chapter, {PlatformFile? videoFile, PlatformFile? pdfFile}) async {
    final uri = Uri.parse('$baseCoursesUrl/$courseId/chapters/$chapterId');
    final request = http.MultipartRequest('PUT', uri);
    
    request.headers.addAll(await AuthService.getAuthHeaders());

    request.fields['title'] = chapter.title;
    if (chapter.description != null) request.fields['description'] = chapter.description!;
    if (chapter.orderNumber != null) request.fields['orderNumber'] = chapter.orderNumber.toString();

    if (videoFile != null && videoFile.bytes != null) {
      final contentType = MediaType('video', videoFile.extension ?? 'mp4');
      request.files.add(http.MultipartFile.fromBytes('video', videoFile.bytes!, filename: videoFile.name, contentType: contentType));
    }

    if (pdfFile != null && pdfFile.bytes != null) {
      final contentType = MediaType('application', 'pdf');
      request.files.add(http.MultipartFile.fromBytes('pdf', pdfFile.bytes!, filename: pdfFile.name, contentType: contentType));
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode == 200) {
      return Chapter.fromJson(json.decode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update chapter: ${res.statusCode} ${res.body}');
  }

  static Future<void> deleteChapter(int courseId, int chapterId) async {
    final res = await http.delete(Uri.parse('$baseCoursesUrl/$courseId/chapters/$chapterId'), headers: await AuthService.getAuthHeaders());
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete chapter (${res.statusCode}): ${res.body}');
    }
  }
}

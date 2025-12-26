import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class AiService {
  static const String baseUrl = 'http://localhost:8080/api/courses';

  static Future<Map<String, String>> generateChapterInfo(int courseId, PlatformFile pdfFile) async {
    final uri = Uri.parse('$baseUrl/$courseId/chapters/analyze-pdf');
    final request = http.MultipartRequest('POST', uri);

    if (pdfFile.bytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'pdf',
        pdfFile.bytes!,
        filename: pdfFile.name,
      ));
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return {
        'title': data['title'] ?? '',
        'description': data['description'] ?? '',
      };
    }
    throw Exception('Erreur lors de la génération IA: ${res.statusCode}');
  }
}

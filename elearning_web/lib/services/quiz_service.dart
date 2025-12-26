import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz.dart';
import 'auth_service.dart';

class QuizService {
  static const String baseUrl = "http://localhost:8080/api/quiz";

  static Future<Quiz> createQuiz(Quiz quiz) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: await AuthService.getAuthHeaders(),
      body: jsonEncode({
        'title': quiz.title,
        'courseId': quiz.courseId,
      }),
    );
    if (response.statusCode == 200) {
      return Quiz.fromJson(jsonDecode(response.body));
    }
    throw Exception("Erreur création quizz: ${response.body}");
  }

  static Future<Question> addQuestion(int quizId, Question question) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$quizId/question'),
      headers: await AuthService.getAuthHeaders(),
      body: jsonEncode(question.toJson()),
    );
    if (response.statusCode == 200) {
      return Question.fromJson(jsonDecode(response.body));
    }
    throw Exception("Erreur ajout question");
  }

  static Future<Answer> addAnswer(int questionId, Answer answer) async {
    final response = await http.post(
      Uri.parse('$baseUrl/question/$questionId/answer'),
      headers: await AuthService.getAuthHeaders(),
      body: jsonEncode(answer.toJson()),
    );
    if (response.statusCode == 200) {
      return Answer.fromJson(jsonDecode(response.body));
    }
    throw Exception("Erreur ajout réponse");
  }

  static Future<Quiz> getQuiz(int quizId) async {
    final response = await http.get(Uri.parse('$baseUrl/$quizId'), headers: await AuthService.getAuthHeaders());
    if (response.statusCode == 200) {
      return Quiz.fromJson(jsonDecode(response.body));
    }
    throw Exception("Erreur récupération quizz");
  }

  static Future<StudentQuiz> submitQuiz(int quizId, String studentId, List<int> answerIds) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$quizId/submit/$studentId'),
      headers: await AuthService.getAuthHeaders(),
      body: jsonEncode(answerIds),
    );
    if (response.statusCode == 200) {
      return StudentQuiz.fromJson(jsonDecode(response.body));
    }
    throw Exception("Erreur soumission quizz");
  }
}

import 'dart:convert';

class Quiz {
  final int? id;
  final String title;
  final DateTime? createdAt;
  final int? courseId;
  final List<Question>? questions;

  Quiz({
    this.id,
    required this.title,
    this.createdAt,
    this.courseId,
    this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      courseId: json['courseId'],
      questions: json['questions'] != null
          ? (json['questions'] as List).map((i) => Question.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      if (courseId != null) 'courseId': courseId,
    };
  }
}

class Question {
  final int? id;
  final String text;
  final List<Answer>? answers;

  Question({this.id, required this.text, this.answers});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'] ?? '',
      answers: json['answers'] != null
          ? (json['answers'] as List).map((i) => Answer.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'text': text,
    };
  }
}

class Answer {
  final int? id;
  final String text;
  final bool isCorrect;

  Answer({this.id, required this.text, this.isCorrect = false});

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      text: json['text'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'text': text,
      'isCorrect': isCorrect,
    };
  }
}

class StudentQuiz {
  final int? quizId;
  final String? studentId;
  final double? score; // Using double to handle percentage if needed, but backend gives int count

  StudentQuiz({this.quizId, this.studentId, this.score});

  factory StudentQuiz.fromJson(Map<String, dynamic> json) {
    // Backend StudentQuiz entity has .quiz (entity) and .id (Long) and .score (int)
    int? qId;
    if (json['quiz'] != null) {
      qId = json['quiz']['id'];
    } else {
      qId = json['quizId'];
    }

    String? sId = json['studentId']?.toString();

    return StudentQuiz(
      quizId: qId,
      studentId: sId,
      score: (json['score'] as num?)?.toDouble(),
    );
  }
}

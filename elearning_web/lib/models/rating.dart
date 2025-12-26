import 'user.dart';

class Rating {
  final int? id;
  final int score;
  final String? comment;
  final DateTime? createdAt;
  final User? student;

  Rating({
    this.id,
    required this.score,
    this.comment,
    this.createdAt,
    this.student,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      score: json['score'] ?? 0,
      comment: json['comment'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      student: json['student'] != null 
          ? User.fromJson(json['student']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
      'comment': comment,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class RatingRequest {
  final int courseId;
  final int score;
  final String? comment;

  RatingRequest({
    required this.courseId,
    required this.score,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'score': score,
      'comment': comment,
    };
  }
}

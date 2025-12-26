import 'user.dart';
import 'course.dart';

class Enrollment {
  final int? id;
  final User? user;
  final Course? course;
  final DateTime? enrolledAt;

  Enrollment({
    this.id,
    this.user,
    this.course,
    this.enrolledAt,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      course: json['course'] != null ? Course.fromJson(json['course']) : null,
      enrolledAt: json['enrolledAt'] != null ? DateTime.parse(json['enrolledAt']) : null,
    );
  }
}

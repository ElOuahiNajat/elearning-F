class Course {
  final int? id;
  final String title;
  final String description;
  final String? category;
  final String? videoUrl;
  final String? pdfUrl;

  Course({
    this.id,
    required this.title,
    required this.description,
    this.category,
    this.videoUrl,
    this.pdfUrl,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.parse(json['id'].toString()) : null),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'],
      videoUrl: json['videoUrl'],
      pdfUrl: json['pdfUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      if (category != null) 'category': category,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (pdfUrl != null) 'pdfUrl': pdfUrl,
    };
  }
}

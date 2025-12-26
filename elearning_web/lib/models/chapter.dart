class Chapter {
  final int? id;
  final String title;
  final String? description;
  final int? orderNumber;
  final String? videoUrl;
  final String? pdfUrl;

  Chapter({this.id, required this.title, this.description, this.orderNumber, this.videoUrl, this.pdfUrl});

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        id: json['id'] is int ? json['id'] : (json['id'] != null ? int.parse(json['id'].toString()) : null),
        title: json['title'] ?? '',
        description: json['description'],
        orderNumber: json['orderNumber'] is int ? json['orderNumber'] : (json['orderNumber'] != null ? int.parse(json['orderNumber'].toString()) : null),
        videoUrl: json['videoUrl'],
        pdfUrl: json['pdfUrl'],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'title': title,
        if (description != null) 'description': description,
        if (orderNumber != null) 'orderNumber': orderNumber,
        if (videoUrl != null) 'videoUrl': videoUrl,
        if (pdfUrl != null) 'pdfUrl': pdfUrl,
      };
}

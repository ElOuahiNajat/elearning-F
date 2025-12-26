import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/course.dart';
import '../services/enrollment_service.dart';
import '../services/rating_service.dart';
import '../pages/chapters_page.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseCard extends StatefulWidget {
  final Course course;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isEnrolled;
  final String? currentUserId;
  final VoidCallback? onEnrollSuccess;
  final bool isAdmin;

  const CourseCard({
    super.key,
    required this.course,
    this.onEdit,
    this.onDelete,
    this.isEnrolled = false,
    this.currentUserId,
    this.onEnrollSuccess,
    this.isAdmin = false,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  double _averageRating = 0.0;
  int _ratingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  Future<void> _loadRating() async {
    if (widget.course.id == null) return;
    try {
      final ratings = await RatingService.getRatingsByCourse(widget.course.id!);
      if (mounted) {
        setState(() {
          _ratingCount = ratings.length;
          if (ratings.isNotEmpty) {
            _averageRating = ratings.map((r) => r.score).reduce((a, b) => a + b) / ratings.length;
          }
        });
      }
    } catch (e) {
      print('Error loading rating for course ${widget.course.id}: $e');
    }
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Mathématiques': Colors.deepPurple,
      'Sciences': Colors.blue,
      'Histoire': Colors.amber,
      'Langues': Colors.green,
      'Informatique': Colors.indigo,
      'Art': Colors.pink,
      'Sport': Colors.orange,
    };
    return colors[category] ?? Colors.deepPurple;
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(widget.course.category ?? 'Général');
    
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (widget.course.id == null) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChaptersPage(
                courseId: widget.course.id!,
                courseTitle: widget.course.title,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    categoryColor.withOpacity(0.9),
                    categoryColor.withOpacity(0.6),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Pattern decoration
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      Iconsax.book_1,
                      size: 80,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  
                  // Category tag
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.course.category ?? 'Général',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.course.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Iconsax.star5, size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  _averageRating.toStringAsFixed(1),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  ' ($_ratingCount)',
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8), // Added space for description
                            Text(
                              widget.course.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.isAdmin)
                        PopupMenuButton<String>(
                          icon: Icon(
                            Iconsax.more,
                            size: 20,
                            color: Colors.grey.shade400,
                          ),
                          onSelected: (value) {
                            if (value == 'edit' && widget.onEdit != null) widget.onEdit!();
                            if (value == 'delete' && widget.onDelete != null) widget.onDelete!();
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Iconsax.edit_2, size: 18),
                                  const SizedBox(width: 10),
                                  const Text('Modifier'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Iconsax.trash, size: 18, color: Colors.red),
                                  const SizedBox(width: 10),
                                  const Text('Supprimer', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Action button
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (widget.course.id == null) return;
                      
                      if (!widget.isEnrolled) {
                        if (widget.currentUserId == null) return;
                        try {
                          await EnrollmentService.enroll(widget.course.id!, widget.currentUserId!);
                          if (widget.onEnrollSuccess != null) widget.onEnrollSuccess!();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Inscription réussie !')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur: $e')),
                          );
                        }
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChaptersPage(
                              courseId: widget.course.id!,
                              courseTitle: widget.course.title,
                            ),
                          ),
                        );
                      }
                    },
                    icon: Icon(widget.isEnrolled ? Iconsax.play : Iconsax.add_circle, size: 18),
                    label: Text(widget.isEnrolled ? 'Accéder au cours' : 'S\'inscrire'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isEnrolled ? categoryColor : Colors.grey.shade100,
                      foregroundColor: widget.isEnrolled ? Colors.white : categoryColor,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: widget.isEnrolled ? BorderSide.none : BorderSide(color: categoryColor),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

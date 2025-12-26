import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/chapter.dart';
import '../pages/chapter_detail_page.dart';

class ChapterCard extends StatelessWidget {
  final int courseId;
  final Chapter chapter;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isAdmin;

  const ChapterCard({
    super.key,
    required this.courseId,
    required this.chapter,
    required this.onEdit,
    required this.onDelete,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChapterDetailPage(courseId: courseId, chapter: chapter))),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${chapter.orderNumber ?? '#'}',
                    style: TextStyle(
                      color: Colors.deepPurple.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    if (chapter.description != null && chapter.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        chapter.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
              if (isAdmin)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Iconsax.edit, size: 20),
                      onPressed: onEdit,
                      color: Colors.grey.shade600,
                      tooltip: 'Modifier',
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.trash, size: 20),
                      onPressed: onDelete,
                      color: Colors.red.shade400,
                      tooltip: 'Supprimer',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

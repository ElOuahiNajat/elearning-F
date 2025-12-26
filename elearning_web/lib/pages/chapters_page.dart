import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/chapter.dart';
import '../services/chapter_service.dart';
import '../services/auth_service.dart';
import '../widgets/chapter_card.dart';
import 'edit_chapter_page.dart';
import 'quiz_management_page.dart';
import '../services/rating_service.dart';
import '../models/rating.dart';
import '../widgets/rating_bottom_sheet.dart';

class ChaptersPage extends StatefulWidget {
  final int courseId;
  final String courseTitle;
  const ChaptersPage({super.key, required this.courseId, required this.courseTitle});

  @override
  State<ChaptersPage> createState() => _ChaptersPageState();
}

class _ChaptersPageState extends State<ChaptersPage> {
  late Future<List<Chapter>> _chapters;
  final _searchController = TextEditingController();
  String? _userRole;
  List<Rating> _ratings = [];
  double _averageRating = 0;

  @override
  void initState() {
    super.initState();
    _chapters = ChapterService.getChaptersByCourse(widget.courseId);
    _loadRole();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    try {
      final ratings = await RatingService.getRatingsByCourse(widget.courseId);
      if (mounted) {
        setState(() {
          _ratings = ratings;
          if (ratings.isNotEmpty) {
            _averageRating = ratings.map((r) => r.score).reduce((a, b) => a + b) / ratings.length;
          } else {
            _averageRating = 0;
          }
        });
      }
    } catch (e) {
      print('Error loading ratings: $e');
    }
  }

  void _showRatingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RatingBottomSheet(
        courseId: widget.courseId,
        onRatingSubmitted: () {
          _loadRatings();
        },
      ),
    );
  }

  Future<void> _loadRole() async {
    final role = await AuthService.getUserRole();
    if (mounted) setState(() => _userRole = role);
  }

  bool get _isAdmin => _userRole == 'ADMIN' || _userRole == 'ROLE_ADMIN';

  Future<void> _refresh() async {
    setState(() {
      _chapters = ChapterService.getChaptersByCourse(widget.courseId);
    });
  }

  void _performSearch(String query) {
    // Note: If ChapterService doesn't have searchChapters, we might need to filter locally.
    // Assuming user wants local filtering if API doesn't exist, or will implement API later.
    // For now, I'll filter locally since I haven't seen searchChapters in the service yet.
     setState(() {
      _chapters = ChapterService.getChaptersByCourse(widget.courseId).then((list) {
         if (query.trim().isEmpty) return list;
         return list.where((c) => c.title.toLowerCase().contains(query.toLowerCase())).toList();
      });
    });
  }

  Future<void> _editChapter(Chapter? ch) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditChapterPage(courseId: widget.courseId, chapter: ch),
      ),
    );
    _refresh();
  }

  Future<void> _deleteChapter(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce chapitre ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ChapterService.deleteChapter(widget.courseId, id);
        _showSuccess('Chapitre supprimé avec succès');
        _refresh();
      } catch (e) {
        _showError('Erreur: $e');
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.note_remove, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            'Aucun chapitre',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Commencez par créer votre premier chapitre',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          if (_isAdmin) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _editChapter(null),
              icon: const Icon(Iconsax.add),
              label: const Text('Créer un chapitre'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.courseTitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              'Gestion des chapitres',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizManagementPage(
                    courseId: widget.courseId,
                    courseTitle: widget.courseTitle,
                  ),
                ),
              );
            },
            icon: const Icon(Iconsax.note_2),
            label: const Text('Quizz'),
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Iconsax.star),
                if (_averageRating > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 10,
                        minHeight: 10,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showRatingSheet,
            tooltip: 'Avis et Notes',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un chapitre...',
                prefixIcon: const Icon(Iconsax.search_normal),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Iconsax.close_circle),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: _performSearch,
            ),
          ),
          if (_isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () => _editChapter(null),
                icon: const Icon(Iconsax.add_circle, size: 20),
                label: const Text('Nouveau chapitre'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Chapter>>(
              future: _chapters,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.warning_2, size: 60, color: Colors.orange.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur de chargement',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                final chapters = snapshot.data ?? [];
                if (chapters.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  color: Colors.deepPurple,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: chapters.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final chapter = chapters[index];
                      return ChapterCard(
                        courseId: widget.courseId,
                        chapter: chapter,
                        onEdit: () => _editChapter(chapter),
                        onDelete: () => _deleteChapter(chapter.id!),
                        isAdmin: _isAdmin,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

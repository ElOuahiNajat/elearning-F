import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/course.dart';
import '../services/course_service.dart';
import '../widgets/course_card.dart';
import '../services/enrollment_service.dart';
import '../services/recommendation_service.dart';
import '../services/auth_service.dart';
import '../models/enrollment.dart';
import 'edit_course_page.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  late Future<List<Course>> _courses;
  final TextEditingController _searchController = TextEditingController();
  List<int> _enrolledCourseIds = [];
  bool _isLoadingEnrollments = true;
  String? _userRole;
  // Use a valid UUID found in the backend
  final String _currentUserId = "3dd4d80f-58de-4e6e-9cbb-86c25527f33b";

  @override
  void initState() {
    super.initState();
    _courses = CourseService.getCourses();
    _loadEnrollments();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await AuthService.getUserRole();
    if (mounted) setState(() => _userRole = role);
  }

  bool get _isAdmin => _userRole == 'ADMIN' || _userRole == 'ROLE_ADMIN';

  Future<void> _loadEnrollments() async {
    try {
      final enrollments = await EnrollmentService.getUserEnrollments(_currentUserId);
      setState(() {
        _enrolledCourseIds = enrollments.map((e) => e.course?.id).whereType<int>().toList();
        _isLoadingEnrollments = false;
      });
    } catch (e) {
      print('Erreur chargement inscriptions: $e');
      setState(() => _isLoadingEnrollments = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _courses = CourseService.getCourses().then((list) {
         if (query.trim().isEmpty) return list;
         return list.where((c) => c.title.toLowerCase().contains(query.toLowerCase())).toList();
      });
    });
  }

  Future<void> _deleteCourse(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous vraiment supprimer ce cours ? Tous les chapitres associés seront également supprimés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await CourseService.deleteCourse(id);
        setState(() {
          _courses = CourseService.getCourses();
        });
        _showSnackbar('Cours supprimé avec succès', Colors.green);
      } catch (e) {
        _showSnackbar('Erreur lors de la suppression: $e', Colors.red);
      }
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _editCourse(Course? course) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditCoursePage(course: course),
      ),
    );

    setState(() {
      _courses = CourseService.getCourses();
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.book, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            'Aucun cours disponible',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Créez votre premier cours pour commencer',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          if (_isAdmin) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _editCourse(null),
              icon: const Icon(Iconsax.add_circle),
              label: const Text('Créer un cours'),
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
              'Plateforme Éducative',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              'Mes Cours',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter),
            onPressed: () {},
            tooltip: 'Filtrer',
          ),
          if (_isAdmin)
            IconButton(
              icon: const Icon(Iconsax.add),
              onPressed: () => _editCourse(null),
              tooltip: 'Nouveau cours',
            ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un cours...',
                  prefixIcon: const Icon(Iconsax.search_normal_1),
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
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onSubmitted: _performSearch,
              ),
            ),
            const SizedBox(height: 16),
            

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Explorez tous les cours',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ),

            Expanded(
              child: FutureBuilder<List<Course>>(
                future: _courses,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  final courses = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      final isEnrolled = _enrolledCourseIds.contains(course.id);
                      return CourseCard(
                        course: course,
                        isEnrolled: isEnrolled,
                        currentUserId: _currentUserId,
                        onEnrollSuccess: _loadEnrollments,
                        onEdit: () => _editCourse(course),
                        onDelete: () => _deleteCourse(course.id!),
                        isAdmin: _isAdmin,
                      );
                    },
                  );
                },
              ),
            ),

          ],
        ),
      ),
      floatingActionButton: _isAdmin ? FloatingActionButton(
        onPressed: () => _editCourse(null),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Iconsax.add),
      ) : null,
    );
  }
}

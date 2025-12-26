import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/course.dart';
import '../services/recommendation_service.dart';
import '../services/enrollment_service.dart';
import '../widgets/course_card.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  late Future<List<Course>> _recommendedCourses;
  List<int> _enrolledCourseIds = [];
  bool _isLoadingEnrollments = true;
  final String _currentUserId = "3dd4d80f-58de-4e6e-9cbb-86c25527f33b";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _recommendedCourses = RecommendationService.getRecommendedCourses(_currentUserId);
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    try {
      final enrollments = await EnrollmentService.getUserEnrollments(_currentUserId);
      if (mounted) {
        setState(() {
          _enrolledCourseIds = enrollments.map((e) => e.course?.id).whereType<int>().toList();
          _isLoadingEnrollments = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingEnrollments = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepPurple,
                      Colors.deepPurple.shade800,
                      Colors.blue.shade900,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Icon(
                        Iconsax.magic_star,
                        size: 200,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Iconsax.magic_star, color: Colors.amber, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'POUR VOUS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Recommandations 🌟',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            'Des cours sélectionnés par notre IA spécialement pour vos intérêts.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            backgroundColor: Colors.deepPurple,
            elevation: 0,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: FutureBuilder<List<Course>>(
              future: _recommendedCourses,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || _isLoadingEnrollments) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(child: Text('Erreur: ${snapshot.error}')),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: Icon(Iconsax.magic_star, size: 80, color: Colors.grey.shade300),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Pas encore de recommandations',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Inscrivez-vous à des cours pour que notre IA puisse analyser vos préférences !',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final courses = snapshot.data!;
                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final course = courses[index];
                      return CourseCard(
                        course: course,
                        isEnrolled: _enrolledCourseIds.contains(course.id),
                        currentUserId: _currentUserId,
                        onEnrollSuccess: () {
                          _loadData();
                          setState(() {});
                        },
                      );
                    },
                    childCount: courses.length,
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

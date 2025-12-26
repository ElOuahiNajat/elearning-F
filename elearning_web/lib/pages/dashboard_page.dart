import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconsax/iconsax.dart';
import '../services/course_service.dart';
import '../services/user_service.dart';
import '../models/course.dart';
import '../models/user.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = true;
  int _totalUsers = 0;
  int _totalCourses = 0;
  Map<String, int> _usersByRole = {};
  List<Course> _latestCourses = [];
  List<Course> _mostChaptersCourses = [];
  List<User> _latestUsers = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Execute calls sequentially or with separate catch to identify the culprit
      // This is better for debugging 500 errors from backend
      try { _totalUsers = await UserService.getTotalUsers(); } catch (e) { print('Error totalUsers: $e'); }
      try { _totalCourses = await CourseService.getTotalCourses(); } catch (e) { print('Error totalCourses: $e'); }
      try { _usersByRole = await UserService.getUserCountByRole(); } catch (e) { print('Error roleCount: $e'); }
      try { _latestCourses = await CourseService.getLatestCourses(); } catch (e) { print('Error latestCourses: $e'); }
      try { _latestUsers = await UserService.getLatestUsers(); } catch (e) { print('Error latestUsers: $e'); }
      try { _mostChaptersCourses = await CourseService.getCoursesWithMostChapters(); } catch (e) { print('Error mostChapters: $e'); }

      setState(() {
        _isLoading = false;
        if (_totalUsers == 0 && _totalCourses == 0 && _error == null) {
           // If everything is zero but no exception was caught at the top,
           // maybe some calls failed silently.
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.danger, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Iconsax.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Text(
                'Tableau de Bord',
                style: TextStyle(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Container(color: Colors.white),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Utilisateurs',
                        value: _totalUsers.toString(),
                        icon: Iconsax.profile_2user,
                        color: Colors.blue,
                        subtitle: 'Total inscrits',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _StatCard(
                        title: 'Cours',
                        value: _totalCourses.toString(),
                        icon: Iconsax.book_1,
                        color: Colors.deepPurple,
                        subtitle: 'Cours publiés',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Roles Chart
                    Expanded(
                      flex: 2,
                      child: _ChartSection(
                        title: 'Répartition des Rôles',
                        pieData: _buildPieSections(),
                        legend: _usersByRole,
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Stats/Lists
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _ListSection(
                            title: 'Dernières Inscriptions',
                            icon: Iconsax.user_add,
                            items: _latestUsers.map((u) => _ListItem(
                              title: '${u.firstName} ${u.lastName}',
                              subtitle: u.email,
                              trailing: _RoleChip(role: u.role),
                              leading: CircleAvatar(
                                backgroundColor: _getRoleColor(u.role).withOpacity(0.1),
                                child: Text(u.firstName[0], style: TextStyle(color: _getRoleColor(u.role))),
                              ),
                            )).toList(),
                          ),
                          const SizedBox(height: 24),
                          _ListSection(
                            title: 'Cours Populaires',
                            icon: Iconsax.crown,
                            items: _mostChaptersCourses.map((c) => _ListItem(
                              title: c.title,
                              subtitle: '${c.category ?? "Général"}',
                              trailing: Text('Top', style: TextStyle(color: Colors.amber.shade700, fontWeight: FontWeight.bold)),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Iconsax.book, color: Colors.amber, size: 20),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    return _usersByRole.entries.map((e) {
      final color = _getRoleColor(e.key);
      return PieChartSectionData(
        color: color,
        value: e.value.toDouble(),
        title: '',
        radius: 60,
        showTitle: false,
      );
    }).toList();
  }

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN': return const Color(0xFFEF4444);
      case 'TEACHER': return const Color(0xFFF59E0B);
      case 'STUDENT': return const Color(0xFF3B82F6);
      default: return const Color(0xFF64748B);
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.subtitle, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: const Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(color: const Color(0xFF0F172A), fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  final String title;
  final List<PieChartSectionData> pieData;
  final Map<String, int> legend;

  const _ChartSection({required this.title, required this.pieData, required this.legend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 50,
                sections: pieData,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ...legend.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: _getRoleColor(e.key),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(e.key, style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w500)),
                const Spacer(),
                Text(e.value.toString(), style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN': return const Color(0xFFEF4444);
      case 'TEACHER': return const Color(0xFFF59E0B);
      case 'STUDENT': return const Color(0xFF3B82F6);
      default: return const Color(0xFF64748B);
    }
  }
}

class _ListSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> items;

  const _ListSection({required this.title, required this.icon, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.deepPurple, size: 20),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget leading;
  final Widget trailing;

  const _ListItem({required this.title, required this.subtitle, required this.leading, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String role;
  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    Color color = const Color(0xFF64748B);
    if (role.toUpperCase() == 'ADMIN') color = const Color(0xFFEF4444);
    if (role.toUpperCase() == 'TEACHER') color = const Color(0xFFF59E0B);
    if (role.toUpperCase() == 'STUDENT') color = const Color(0xFF3B82F6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

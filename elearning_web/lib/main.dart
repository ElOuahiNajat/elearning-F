// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'pages/courses_page.dart';
import 'pages/users_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/recommendations_page.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const ElearningApp());
}

class ElearningApp extends StatelessWidget {
  const ElearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Learning Web',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: Colors.deepPurple,
          secondary: Colors.amber,
          background: Colors.grey.shade50,
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: false,
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.grey.shade800,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: const IconThemeData(color: Colors.deepPurple),
        ),
      ),
      home: FutureBuilder<bool>(
        future: AuthService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data == true) {
            return const MainNavigation();
          }
          return const LoginPage();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final role = await AuthService.getUserRole();
    final isAdmin = role == 'ADMIN' || role == 'ROLE_ADMIN';
    setState(() {
      _userRole = role;
      _isLoading = false;
      // Si c'est un utilisateur simple, on commence sur l'onglet Cours (index 1)
      // car le Dashboard est masqué pour eux.
      if (!isAdmin) {
        _selectedIndex = 1;
      }
    });
  }

  List<Map<String, dynamic>> _getNavItems() {
    final isAdmin = _userRole == 'ADMIN' || _userRole == 'ROLE_ADMIN';
    return [
      if (isAdmin) {'icon': Iconsax.chart_2, 'activeIcon': Iconsax.chart_21, 'label': 'Tableau de bord', 'page': const DashboardPage()},
      {'icon': Iconsax.book, 'activeIcon': Iconsax.book5, 'label': 'Cours', 'page': const CoursesPage()},
      if (!isAdmin) {'icon': Iconsax.star, 'activeIcon': Iconsax.star5, 'label': 'Recommandations', 'page': const RecommendationsPage()},
      if (isAdmin) {'icon': Iconsax.people, 'activeIcon': Iconsax.people5, 'label': 'Utilisateurs', 'page': const UsersPage()},
      {'icon': Iconsax.logout, 'label': 'Déconnexion', 'isLogout': true},
    ];
  }

  void _onItemTapped(int index, List<Map<String, dynamic>> items) {
    if (items[index]['isLogout'] == true) {
      _logout();
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Iconsax.logout, color: Colors.red),
            SizedBox(width: 12),
            Text('Déconnexion'),
          ],
        ),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final items = _getNavItems();

    return Scaffold(
      body: items[_selectedIndex]['page'] as Widget,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => _onItemTapped(index, items),
        destinations: items.map((item) {
          if (item['isLogout'] == true) {
            return NavigationDestination(
              icon: Icon(item['icon'] as IconData, color: Colors.red.shade400),
              label: item['label'] as String,
            );
          }
          return NavigationDestination(
            icon: Icon(item['icon'] as IconData),
            selectedIcon: Icon(item['activeIcon'] as IconData),
            label: item['label'] as String,
          );
        }).toList(),
      ),
    );
  }
}

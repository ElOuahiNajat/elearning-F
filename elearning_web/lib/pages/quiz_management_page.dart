import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import '../services/auth_service.dart';
import 'edit_quiz_page.dart';
import 'take_quiz_page.dart';

class QuizManagementPage extends StatefulWidget {
  final int courseId;
  final String courseTitle;

  const QuizManagementPage({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<QuizManagementPage> createState() => _QuizManagementPageState();
}

class _QuizManagementPageState extends State<QuizManagementPage> {
  bool _isLoading = false;
  Quiz? _activeQuiz;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await AuthService.getUserRole();
    if (mounted) setState(() => _userRole = role);
  }

  bool get _isAdmin => _userRole == 'ADMIN' || _userRole == 'ROLE_ADMIN';

  Future<void> _loadQuiz() async {
    // This is tricky without a "list by course" endpoint.
    // We'll try a common pattern or a specific ID if stored.
    // For now, let's assume we can fetch it or just show "Create"
    setState(() => _isLoading = true);
    try {
       // Placeholder: In a real app, we'd fetch List<Quiz> by courseId
       // Since the provided controller only has getQuiz(id), 
       // we might need to store the quizId somewhere or search.
    } catch (e) {
      print('Error loading quiz: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Quiz - ${widget.courseTitle}'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(Iconsax.note_2, size: 80, color: Colors.deepPurple.shade200),
                          const SizedBox(height: 24),
                          Text(
                            _isAdmin ? 'Configuration du Quiz' : 'Prêt pour le Quiz ?',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isAdmin 
                              ? 'Ajoutez des questions et des réponses pour évaluer vos étudiants.'
                              : 'Testez vos connaissances en répondant aux questions préparées pour ce cours.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 40),
                          if (_isAdmin) ...[
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditQuizPage(courseId: widget.courseId),
                                    ),
                                  );
                                },
                                icon: const Icon(Iconsax.add_circle),
                                label: const Text('Créer un nouveau Quiz', style: TextStyle(fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _showIdDialog();
                              },
                              icon: const Icon(Iconsax.play),
                              label: const Text('Tester un Quiz (Entrer ID)', style: TextStyle(fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isAdmin ? Colors.white : Colors.deepPurple,
                                foregroundColor: _isAdmin ? Colors.deepPurple : Colors.white,
                                side: _isAdmin ? BorderSide(color: Colors.deepPurple.shade200) : BorderSide.none,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _showIdDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Entrer ID du Quiz'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Ex: 1'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final id = int.tryParse(ctrl.text);
              if (id != null) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TakeQuizPage(quizId: id)),
                );
              }
            },
            child: const Text('Ouvrir'),
          ),
        ],
      ),
    );
  }
}

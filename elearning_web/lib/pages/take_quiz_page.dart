import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';

class TakeQuizPage extends StatefulWidget {
  final int quizId;

  const TakeQuizPage({super.key, required this.quizId});

  @override
  State<TakeQuizPage> createState() => _TakeQuizPageState();
}

class _TakeQuizPageState extends State<TakeQuizPage> {
  Quiz? _quiz;
  bool _isLoading = true;
  String? _error;
  
  // Maps Question ID -> Selected Answer ID
  final Map<int, int> _selectedAnswers = {};
  bool _isSubmitting = false;
  StudentQuiz? _result;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final quiz = await QuizService.getQuiz(widget.quizId);
      setState(() {
        _quiz = quiz;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_quiz == null || _quiz!.questions == null) return;
    
    // Check if all questions are answered
    if (_selectedAnswers.length < _quiz!.questions!.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez répondre à toutes les questions.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // Note: Utilisation d'un ID existant pour éviter l'erreur 500 "Student not found"
      // Idéalement, cet ID devrait provenir d'un système d'auth ou d'une sélection.
      const studentId = "dc540e8f-c54c-4734-aff0-f62f309d57a4";
      final result = await QuizService.submitQuiz(
        widget.quizId, 
        studentId, 
        _selectedAnswers.values.toList()
      );
      setState(() {
        _result = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Erreur: $_error')),
      );
    }

    if (_result != null) {
      return _buildResultView();
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_quiz!.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...List.generate(_quiz!.questions!.length, (index) {
                  final q = _quiz!.questions![index];
                  return _buildQuestionCard(q, index + 1);
                }),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isSubmitting 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Soumettre le Quiz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Question q, int number) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Question $number', style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(q.text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            if (q.answers != null)
              ...q.answers!.map((a) {
                final isSelected = _selectedAnswers[q.id!] == a.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => setState(() => _selectedAnswers[q.id!] = a.id!),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected ? Colors.deepPurple.withOpacity(0.05) : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Iconsax.tick_circle5 : Iconsax.record,
                            color: isSelected ? Colors.deepPurple : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(a.text, style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ))),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.medal_star, size: 100, color: Colors.orange),
              const SizedBox(height: 24),
              const Text('Quiz Terminé !', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Votre score est de :', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text('${_result!.score!.toStringAsFixed(0)}%', 
                style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: Colors.deepPurple)),
              const SizedBox(height: 48),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Retour au cours'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

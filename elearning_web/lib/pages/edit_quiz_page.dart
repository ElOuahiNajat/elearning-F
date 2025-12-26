import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';

class EditQuizPage extends StatefulWidget {
  final int courseId;
  final Quiz? quiz;

  const EditQuizPage({super.key, required this.courseId, this.quiz});

  @override
  State<EditQuizPage> createState() => _EditQuizPageState();
}

class _EditQuizPageState extends State<EditQuizPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  
  Quiz? _savedQuiz;
  bool _isSaving = false;
  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    if (widget.quiz != null) {
      _savedQuiz = widget.quiz;
      _titleCtrl.text = _savedQuiz!.title;
      _questions = _savedQuiz!.questions ?? [];
    }
  }

  Future<void> _createBaseQuiz() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final quiz = Quiz(
        title: _titleCtrl.text.trim(),
        courseId: widget.courseId,
      );
      _savedQuiz = await QuizService.createQuiz(quiz);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz créé ! Ajoutez maintenant des questions.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _addQuestion() async {
    if (_savedQuiz == null) return;
    
    final textCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nouvelle Question'),
        content: TextField(
          controller: textCtrl,
          decoration: const InputDecoration(labelText: 'Texte de la question'),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, textCtrl.text), child: const Text('Ajouter')),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() => _isSaving = true);
      try {
        final q = await QuizService.addQuestion(_savedQuiz!.id!, Question(text: result));
        setState(() {
          _questions.add(q);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _addAnswer(int questionId, int qIndex) async {
    final textCtrl = TextEditingController();
    bool isCorrect = false;
    
    final result = await showDialog<Answer>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nouvelle Réponse'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: textCtrl, decoration: const InputDecoration(labelText: 'Texte de la réponse')),
              CheckboxListTile(
                title: const Text('Est correcte ?'),
                value: isCorrect,
                onChanged: (v) => setDialogState(() => isCorrect = v ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, Answer(text: textCtrl.text, isCorrect: isCorrect)),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );

    if (result != null && result.text.isNotEmpty) {
      setState(() => _isSaving = true);
      try {
        final a = await QuizService.addAnswer(questionId, result);
        setState(() {
          final q = _questions[qIndex];
          final updatedAnswers = List<Answer>.from(q.answers ?? [])..add(a);
          _questions[qIndex] = Question(id: q.id, text: q.text, answers: updatedAnswers);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(_savedQuiz == null ? 'Nouveau Quiz' : 'Modifier les questions'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          if (_savedQuiz != null)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Iconsax.tick_circle, color: Colors.green),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_savedQuiz == null) _buildQuizForm() else _buildQuestionsEditor(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizForm() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Iconsax.edit, size: 48, color: Colors.deepPurple),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Titre du Quiz', prefixIcon: Icon(Iconsax.text)),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _createBaseQuiz,
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Suivant : Ajouter des questions'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: Colors.deepPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Iconsax.info_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Quiz : ${_savedQuiz!.title}\nAjoutez vos questions ci-dessous.',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            final q = _questions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ExpansionTile(
                initiallyExpanded: true,
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade50,
                  child: Text('${index + 1}', style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                ),
                title: Text(q.text, style: const TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  if (q.answers != null)
                    ...q.answers!.map((a) => ListTile(
                      dense: true,
                      leading: Icon(a.isCorrect ? Iconsax.tick_square : Iconsax.close_square, 
                        color: a.isCorrect ? Colors.green : Colors.grey),
                      title: Text(a.text),
                    )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton.icon(
                      onPressed: () => _addAnswer(q.id!, index),
                      icon: const Icon(Iconsax.add, size: 18),
                      label: const Text('Ajouter une réponse'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _addQuestion,
          icon: const Icon(Iconsax.add_circle),
          label: const Text('Ajouter une question'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

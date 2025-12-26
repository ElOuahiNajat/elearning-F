import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/course.dart';
import '../services/course_service.dart';

class EditCoursePage extends StatefulWidget {
  final Course? course;

  const EditCoursePage({super.key, this.course});

  @override
  State<EditCoursePage> createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  late TextEditingController titleCtrl;
  late TextEditingController descCtrl;
  late TextEditingController categoryCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.course?.title ?? '');
    descCtrl = TextEditingController(text: widget.course?.description ?? '');
    categoryCtrl = TextEditingController(text: widget.course?.category ?? '');
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final updatedCourse = Course(
        id: widget.course?.id,
        title: titleCtrl.text,
        description: descCtrl.text,
        category: categoryCtrl.text,
      );
      try {
        if (widget.course == null) {
          await CourseService.createCourse(updatedCourse);
        } else {
          await CourseService.updateCourse(widget.course!.id!, updatedCourse);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Iconsax.tick_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(widget.course == null ? 'Cours créé avec succès !' : 'Cours mis à jour avec succès !'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pop(context);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modifier le cours',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.info_circle),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Astuce'),
                  content: const Text('Remplissez tous les champs pour créer un cours complet et attrayant pour vos apprenants.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Compris'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple,
              Colors.deepPurple.shade300,
              Colors.grey[50]!,
            ],
            stops: const [0.0, 0.15, 0.15],
          ),
        ),
        child: Column(
          children: [
            // Header éducatif
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Iconsax.teacher,
                      color: Colors.deepPurple,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Éditer votre contenu éducatif',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Améliorez l\'expérience d\'apprentissage',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Formulaire
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Titre
                            _buildFormSection(
                              icon: Iconsax.text_block,
                              title: 'Titre du cours',
                              subtitle: 'Donnez un titre clair et attrayant',
                              child: TextFormField(
                                controller: titleCtrl,
                                decoration: InputDecoration(
                                  hintText: 'Ex: Introduction au Flutter',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  prefixIcon: const Icon(Iconsax.edit, color: Colors.deepPurple),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Le titre est requis';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Description
                            _buildFormSection(
                              icon: Iconsax.document_text,
                              title: 'Description',
                              subtitle: 'Expliquez les objectifs d\'apprentissage',
                              child: TextFormField(
                                controller: descCtrl,
                                decoration: InputDecoration(
                                  hintText: 'Décrivez ce que les apprenants vont maîtriser...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  prefixIcon: const Icon(Iconsax.note, color: Colors.deepPurple),
                                ),
                                maxLines: 4,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'La description est requise';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Catégorie
                            _buildFormSection(
                              icon: Iconsax.category,
                              title: 'Catégorie',
                              subtitle: 'Classifiez pour une meilleure organisation',
                              child: TextFormField(
                                controller: categoryCtrl,
                                decoration: InputDecoration(
                                  hintText: 'Ex: Programmation, Mathématiques, Sciences...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  prefixIcon: const Icon(Iconsax.tag, color: Colors.deepPurple),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Bouton d'enregistrement
                            Center(
                              child: Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.deepPurple, Colors.purple],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurple.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Iconsax.save_2, color: Colors.white),
                                      SizedBox(width: 10),
                                      Text(
                                        'Enregistrer les modifications',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Bouton annuler
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Annuler',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.deepPurple, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    categoryCtrl.dispose();
    super.dispose();
  }
}


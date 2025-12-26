import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:iconsax/iconsax.dart';
import '../models/chapter.dart';
import '../services/chapter_service.dart';
import '../services/ai_service.dart';

class EditChapterPage extends StatefulWidget {
  final int courseId;
  final Chapter? chapter;
  const EditChapterPage({super.key, required this.courseId, this.chapter});

  @override
  State<EditChapterPage> createState() => _EditChapterPageState();
}

class _EditChapterPageState extends State<EditChapterPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _orderCtrl;
  late TextEditingController _videoCtrl;
  late TextEditingController _pdfCtrl;
  PlatformFile? _pickedVideo;
  PlatformFile? _pickedPdf;
  bool _saving = false;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    final c = widget.chapter;
    _titleCtrl = TextEditingController(text: c?.title ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    _orderCtrl = TextEditingController(text: c?.orderNumber?.toString() ?? '');
    _videoCtrl = TextEditingController(text: c?.videoUrl ?? '');
    _pdfCtrl = TextEditingController(text: c?.pdfUrl ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _orderCtrl.dispose();
    _videoCtrl.dispose();
    _pdfCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.video, withData: true);
    if (res != null && res.files.isNotEmpty) {
      setState(() {
        _pickedVideo = res.files.first;
        _videoCtrl.text = _pickedVideo!.name;
      });
    }
  }

  Future<void> _pickPdf() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], withData: true);
    if (res != null && res.files.isNotEmpty) {
      setState(() {
        _pickedPdf = res.files.first;
        _pdfCtrl.text = _pickedPdf!.name;
      });
    }
  }

  Future<void> _generateInfo() async {
    if (_pickedPdf == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez d\'abord sélectionner un PDF.')));
      return;
    }

    setState(() => _generating = true);
    try {
      final info = await AiService.generateChapterInfo(widget.courseId, _pickedPdf!);
      setState(() {
        _titleCtrl.text = info['title'] ?? _titleCtrl.text;
        _descCtrl.text = info['description'] ?? _descCtrl.text;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Champs générés avec succès !')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur IA: $e')));
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final chapter = Chapter(
      id: widget.chapter?.id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      orderNumber: _orderCtrl.text.isEmpty ? null : int.tryParse(_orderCtrl.text.trim()),
      videoUrl: _videoCtrl.text.isEmpty ? null : _videoCtrl.text.trim(),
      pdfUrl: _pdfCtrl.text.isEmpty ? null : _pdfCtrl.text.trim(),
    );

    try {
      if (widget.chapter == null) {
        await ChapterService.createChapter(widget.courseId, chapter, videoFile: _pickedVideo, pdfFile: _pickedPdf);
      } else {
        await ChapterService.updateChapter(widget.courseId, widget.chapter!.id!, chapter, videoFile: _pickedVideo, pdfFile: _pickedPdf);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.chapter == null ? 'Créer chapitre' : 'Modifier chapitre'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 4,
              shadowColor: Colors.black12,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                 padding: const EdgeInsets.all(32),
                 child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: Colors.deepPurple.shade50,
                             shape: BoxShape.circle,
                           ),
                           child: Icon(Iconsax.note_add, size: 40, color: Colors.deepPurple),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Titre',
                          prefixIcon: Icon(Iconsax.text),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Requis' : null
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Iconsax.note_text),
                        ),
                        maxLines: 4
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _orderCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Ordre (numéro)',
                          prefixIcon: Icon(Iconsax.sort),
                        ),
                        keyboardType: TextInputType.number
                      ),
                      const SizedBox(height: 24),
                      _buildFilePicker(
                        label: 'Vidéo du cours',
                        icon: Iconsax.video,
                        controller: _videoCtrl,
                        onPick: _pickVideo,
                      ),
                      const SizedBox(height: 16),
                      _buildFilePicker(
                        label: 'Support PDF',
                        icon: Iconsax.document,
                        controller: _pdfCtrl,
                        onPick: _pickPdf,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          if (_pickedPdf != null)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _generating ? null : _generateInfo,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(color: Colors.deepPurple.shade200),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: _generating 
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Icon(Iconsax.magicpen, size: 20, color: Colors.deepPurple),
                                label: const Text('Générer (IA)', style: TextStyle(color: Colors.deepPurple)),
                              ),
                            ),
                          if (_pickedPdf != null) const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saving ? null : _save,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _saving 
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Enregistrer', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilePicker({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required VoidCallback onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'URL ou fichier sélectionné',
                  prefixIcon: Icon(icon),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                readOnly: true,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: onPick,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black87,
                elevation: 0,
              ),
              icon: const Icon(Iconsax.folder_open),
              label: const Text('Choisir'),
            ),
          ],
        ),
      ],
    );
  }
}

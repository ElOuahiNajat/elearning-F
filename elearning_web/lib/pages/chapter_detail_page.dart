import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:iconsax/iconsax.dart';
import '../models/chapter.dart';

class ChapterDetailPage extends StatefulWidget {
  final int courseId;
  final Chapter chapter;
  const ChapterDetailPage({super.key, required this.courseId, required this.chapter});

  @override
  State<ChapterDetailPage> createState() => _ChapterDetailPageState();
}

class _ChapterDetailPageState extends State<ChapterDetailPage> {
  VideoPlayerController? _controller;
  bool _initializing = false;
  bool _videoError = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final v = widget.chapter.videoUrl;
    if (v != null && v.isNotEmpty) {
      final url = v.startsWith('http') ? v : 'http://localhost:8080/api/courses/${widget.courseId}/chapters/${widget.chapter.id}/video';
      _initVideo(url);
    }
  }

  Future<void> _initVideo(String url) async {
    setState(() => _initializing = true);
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..addListener(() {
          if (mounted) setState(() {
            if (_controller != null && _controller!.value.isInitialized) {
                _isPlaying = _controller!.value.isPlaying;
            }
          });
        });
      await _controller!.initialize();
      if (mounted) setState(() => _initializing = false);
    } catch (e) {
      if (mounted) setState(() {
        _initializing = false;
        _videoError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _openPdf() async {
    var url = widget.chapter.pdfUrl;
    if (url == null || url.isEmpty) return;
    
    if (!url.startsWith('http')) {
      url = 'http://localhost:8080/api/courses/${widget.courseId}/chapters/${widget.chapter.id}/pdf';
    }
    
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, webOnlyWindowName: '_blank');
    } else {
      _showSnackbar('Impossible d\'ouvrir le PDF');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildVideoSection() {
    if (widget.chapter.videoUrl == null || widget.chapter.videoUrl!.isEmpty) {
      return const SizedBox();
    }

    if (_videoError) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Iconsax.video_slash, size: 50, color: Colors.orange.shade300),
              const SizedBox(height: 16),
              Text(
                'Vidéo non disponible',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Le format n\'est pas supporté ou le fichier est inaccessible',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _initializing
                      ? Container(
                          color: Colors.grey.shade100,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.deepPurple.shade400),
                            ),
                          ),
                        )
                      : VideoPlayer(_controller!),
                ),
              ),
              if (!_initializing && _controller != null && _controller!.value.isInitialized)
                Positioned.fill(
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _isPlaying ? 0 : 1,
                      duration: const Duration(milliseconds: 300),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.deepPurple.withOpacity(0.8),
                        child: IconButton(
                          icon: const Icon(Icons.play_arrow, size: 40, color: Colors.white),
                          onPressed: () {
                            _controller!.play();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade100,
                  child: IconButton(
                    icon: Icon(
                      _isPlaying ? Iconsax.pause : Iconsax.play,
                      color: Colors.deepPurple,
                    ),
                    onPressed: () {
                      _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leçon vidéo',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _controller?.value.isInitialized == true
                            ? _formatDuration(_controller!.value.position)
                            : '00:00',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontFamily: 'monospace',
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.export),
                  onPressed: _openVideoExternal,
                  tooltip: 'Ouvrir dans le navigateur',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openVideoExternal() async {
    final url = widget.chapter.videoUrl;
    if (url == null || url.isEmpty) return;
    
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, webOnlyWindowName: '_blank');
    } else {
      _showSnackbar('Impossible d\'ouvrir la vidéo');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ch = widget.chapter;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ch.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip(
                      label: const Text('Chapitre'),
                      backgroundColor: Colors.deepPurple.shade50,
                      labelStyle: const TextStyle(color: Colors.deepPurple),
                      side: BorderSide(color: Colors.deepPurple.shade100),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      ch.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (ch.description != null && ch.description!.isNotEmpty)
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Iconsax.note_text, color: Colors.deepPurple.shade400, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Description',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ch.description!,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildVideoSection(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: (ch.pdfUrl != null && ch.pdfUrl!.isNotEmpty)
                  ? Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: InkWell(
                      onTap: _openPdf,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Iconsax.document, color: Colors.red, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Support de cours',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Télécharger le PDF',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Iconsax.arrow_right, color: Colors.grey.shade400),
                          ],
                        ),
                      ),
                    ),
                  )
                  : const SizedBox(),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours != '00' ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
}

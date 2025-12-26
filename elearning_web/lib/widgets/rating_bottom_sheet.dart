import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/rating.dart';
import '../services/rating_service.dart';
import 'package:google_fonts/google_fonts.dart';

class RatingBottomSheet extends StatefulWidget {
  final int courseId;
  final VoidCallback onRatingSubmitted;

  const RatingBottomSheet({
    super.key,
    required this.courseId,
    required this.onRatingSubmitted,
  });

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  int _selectedScore = 5;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  List<Rating> _ratings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    try {
      final ratings = await RatingService.getRatingsByCourse(widget.courseId);
      setState(() {
        _ratings = ratings;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading ratings: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);
    try {
      await RatingService.addRating(RatingRequest(
        courseId: widget.courseId,
        score: _selectedScore,
        comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
      ));
      widget.onRatingSubmitted();
      _loadRatings();
      _commentController.clear();
      setState(() {
        _selectedScore = 5;
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci pour votre avis !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Avis et Notes',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Partagez votre expérience avec ce cours',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),
                
                // New Rating Form
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            onPressed: () => setState(() => _selectedScore = index + 1),
                            icon: Icon(
                              Iconsax.star5,
                              size: 36,
                              color: index < _selectedScore ? Colors.amber : Colors.grey.shade300,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _commentController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Laissez un commentaire (optionnel)...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitRating,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: _isSubmitting 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Publier mon avis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                Text(
                  'Tous les avis (${_ratings.length})',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_ratings.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Iconsax.star_1, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'Soyez le premier à donner votre avis !',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _ratings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final rating = _ratings[index];
                      return _buildRatingCard(rating);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingCard(Rating rating) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.deepPurple.shade50,
                child: Text(
                  rating.student?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(color: Colors.deepPurple.shade700, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.student?.fullName ?? 'Utilisateur anonyme',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      rating.createdAt != null 
                          ? '${rating.createdAt!.day}/${rating.createdAt!.month}/${rating.createdAt!.year}'
                          : '',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Iconsax.star5,
                    size: 14,
                    color: index < rating.score ? Colors.amber : Colors.grey.shade200,
                  );
                }),
              ),
            ],
          ),
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              rating.comment!,
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}

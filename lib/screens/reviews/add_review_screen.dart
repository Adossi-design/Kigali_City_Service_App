import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/listing_model.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

// screen where users submit a star rating and comment for a listing
class AddReviewScreen extends ConsumerStatefulWidget {
  final ListingModel listing;
  const AddReviewScreen({super.key, required this.listing});

  @override
  ConsumerState<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends ConsumerState<AddReviewScreen> {
  final _commentController = TextEditingController();
  double _rating = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // make sure user selected a star rating
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Please select a star rating', style: GoogleFonts.dmSans()),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }
    // make sure user wrote a comment
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please write a comment', style: GoogleFonts.dmSans()),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) return;

      // fetches the user's display name from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userName = userDoc.data()?['name'] ?? user.email ?? 'Anonymous';

      // saves the review document to the reviews collection
      await FirebaseFirestore.instance.collection('reviews').add({
        'listingId': widget.listing.id,
        'userId': user.uid,
        'userName': userName,
        'comment': _commentController.text.trim(),
        'rating': _rating,
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.dmSans()),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  // returns a text label based on the star rating selected
  String _ratingLabel(double r) {
    switch (r.toInt()) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent!';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate this Service',
            style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.navyCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // card showing which listing is being reviewed
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.navyCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.navyBorder),
                ),
                child: Row(
                  children: [
                    const Text('📍', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.listing.name,
                              style: GoogleFonts.syne(
                                color: AppTheme.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              )),
                          Text(widget.listing.category,
                              style: GoogleFonts.dmSans(
                                  color: AppTheme.gold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text('YOUR RATING',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.muted,
                    letterSpacing: 0.8,
                  )),
              const SizedBox(height: 12),
              // interactive star rating row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => _rating = i + 1.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        i < _rating ? Icons.star : Icons.star_border,
                        color: AppTheme.gold,
                        size: 40,
                      ),
                    ),
                  );
                }),
              ),
              // shows rating label below the stars
              if (_rating > 0)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _ratingLabel(_rating),
                      style: GoogleFonts.dmSans(
                          color: AppTheme.gold,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              // comment text field
              AppTextField(
                label: 'Your Review',
                hint: 'Share your experience with this place…',
                controller: _commentController,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              // submit button with loading indicator
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: AppTheme.navy, strokeWidth: 2))
                      : const Text('⭐  Submit Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

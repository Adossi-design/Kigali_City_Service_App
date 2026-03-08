import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Text(
                'Reviews',
                style: GoogleFonts.syne(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.white,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reviews')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.gold),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            'No reviews yet.\nBe the first to rate a service!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                                color: AppTheme.muted, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  final reviews = snapshot.data!.docs;
                  final avgRating = reviews.fold(
                        0.0,
                        (sum, doc) => sum + (doc['rating'] as num).toDouble(),
                      ) /
                      reviews.length;

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Summary card
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.navyCard, AppTheme.navyLight],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.gold.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 32)),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  avgRating.toStringAsFixed(1),
                                  style: GoogleFonts.syne(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.gold,
                                  ),
                                ),
                                Text(
                                  'Average rating · ${reviews.length} reviews',
                                  style: GoogleFonts.dmSans(
                                    color: AppTheme.muted,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i < avgRating.round()
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: AppTheme.gold,
                                      size: 14,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // All reviews
                      ...reviews.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final rating = (data['rating'] as num).toDouble();
                        final name = data['userName'] ?? 'Anonymous';
                        final comment = data['comment'] ?? '';
                        final listingId = data['listingId'] ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.navyCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.navyBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User name and stars
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color:
                                              AppTheme.gold.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        child: Center(
                                          child: Text(
                                            name.isNotEmpty
                                                ? name[0].toUpperCase()
                                                : '?',
                                            style: GoogleFonts.syne(
                                              color: AppTheme.gold,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: GoogleFonts.syne(
                                              color: AppTheme.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Row(
                                            children: List.generate(5, (i) {
                                              return Icon(
                                                i < rating.round()
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: AppTheme.gold,
                                                size: 12,
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Listing name tag
                              FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('listings')
                                    .doc(listingId)
                                    .get(),
                                builder: (context, listingSnap) {
                                  if (!listingSnap.hasData) {
                                    return const SizedBox();
                                  }
                                  final listingData = listingSnap.data!.data()
                                      as Map<String, dynamic>?;
                                  final listingName =
                                      listingData?['name'] ?? 'Unknown place';
                                  final category =
                                      listingData?['category'] ?? '';
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.navy,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: AppTheme.navyBorder),
                                    ),
                                    child: Text(
                                      '📍 $listingName · $category',
                                      style: GoogleFonts.dmSans(
                                        color: AppTheme.muted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 8),

                              // Comment
                              Text(
                                '"$comment"',
                                style: GoogleFonts.dmSans(
                                  color: AppTheme.muted,
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

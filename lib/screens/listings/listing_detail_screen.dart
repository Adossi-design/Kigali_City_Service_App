import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/listing_model.dart';
import '../../theme/app_theme.dart';
import '../reviews/add_review_screen.dart';

// detail screen for a single listing
class ListingDetailScreen extends ConsumerWidget {
  final ListingModel listing;
  const ListingDetailScreen({super.key, required this.listing});

  // returns the right emoji based on the listing category
  String get categoryEmoji {
    switch (listing.category) {
      case 'Café':
        return '☕';
      case 'Hospital':
        return '🏥';
      case 'Park':
        return '🌿';
      case 'Restaurant':
        return '🍽';
      case 'Police Station':
        return '🚓';
      case 'Library':
        return '📚';
      case 'Tourist Attraction':
        return '🏛';
      default:
        return '📍';
    }
  }

  // opens Google Maps with directions to this listing's coordinates
  Future<void> _launchNavigation() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${listing.latitude},${listing.longitude}&travelmode=driving',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // collapsible header with category emoji
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppTheme.navy,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.navyCard.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: AppTheme.white, size: 20),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.navyCard, AppTheme.navyLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child:
                      Text(categoryEmoji, style: const TextStyle(fontSize: 64)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // listing name and category badge
                  Text(
                    listing.name,
                    style: GoogleFonts.syne(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$categoryEmoji ${listing.category}',
                      style: GoogleFonts.dmSans(
                        color: AppTheme.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // address, contact, and description info rows
                  _infoRow('📍', listing.address),
                  _infoRow('📞', listing.contact),
                  _infoRow('📝', listing.description),

                  const SizedBox(height: 20),

                  // embedded Google Map showing the listing location
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 180,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(listing.latitude, listing.longitude),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('location'),
                            position:
                                LatLng(listing.latitude, listing.longitude),
                            infoWindow: InfoWindow(title: listing.name),
                          ),
                        },
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        scrollGesturesEnabled: false,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // button to open Google Maps navigation
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _launchNavigation,
                      icon: const Icon(Icons.navigation, size: 20),
                      label: const Text('Navigate Here'),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // button to open the review submission screen
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddReviewScreen(listing: listing),
                        ),
                      ),
                      icon: const Icon(Icons.star, size: 20),
                      label: const Text('Rate this service'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.navyCard,
                        foregroundColor: AppTheme.gold,
                        side: const BorderSide(color: AppTheme.gold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // reviews section
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('reviews')
                        .where('listingId', isEqualTo: listing.id)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      // shows placeholder if no reviews exist yet
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.navyCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.navyBorder),
                          ),
                          child: Center(
                            child: Text(
                              'No reviews yet. Be the first to rate!',
                              style: GoogleFonts.dmSans(
                                  color: AppTheme.muted, fontSize: 13),
                            ),
                          ),
                        );
                      }

                      final reviews = snapshot.data!.docs;

                      // calculates average rating from all reviews
                      final avgRating = reviews.fold(
                              0.0,
                              (sum, doc) =>
                                  sum + (doc['rating'] as num).toDouble()) /
                          reviews.length;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // reviews header with average rating
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Reviews',
                                  style: GoogleFonts.syne(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.white,
                                  )),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: AppTheme.gold, size: 16),
                                  Text(
                                    ' ${avgRating.toStringAsFixed(1)} · ${reviews.length} reviews',
                                    style: GoogleFonts.dmSans(
                                        color: AppTheme.muted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // individual review cards
                          ...reviews.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final rating = (data['rating'] as num).toDouble();
                            final name = data['userName'] ?? 'Anonymous';
                            final comment = data['comment'] ?? '';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.navyCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.navyBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // user avatar and name
                                      Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: AppTheme.gold
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Center(
                                              child: Text(
                                                name[0].toUpperCase(),
                                                style: GoogleFonts.syne(
                                                  color: AppTheme.gold,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(name,
                                              style: GoogleFonts.syne(
                                                color: AppTheme.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                              )),
                                        ],
                                      ),
                                      // star rating display
                                      Row(
                                        children: List.generate(
                                          5,
                                          (i) => Icon(
                                            i < rating.round()
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: AppTheme.gold,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // review comment text
                                  Text(
                                    '"$comment"',
                                    style: GoogleFonts.dmSans(
                                      color: AppTheme.muted,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      height: 1.4,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // helper widget for showing an emoji icon next to a text value
  Widget _infoRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                  color: AppTheme.muted, fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

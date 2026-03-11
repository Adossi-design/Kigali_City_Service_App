import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'listing_detail_screen.dart';

// shows every listing the current user has saved
class SavedListingsScreen extends ConsumerWidget {
  const SavedListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(bookmarkedListingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Listings',
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
        child: saved.when(
          loading: () => const AppLoader(),
          error: (e, _) => Center(
            child: Text('Could not load saved listings',
                style: GoogleFonts.dmSans(color: AppTheme.muted)),
          ),
          data: (listings) {
            if (listings.isEmpty) {
              return const EmptyState(
                emoji: '🔖',
                message:
                    'You haven\'t saved any listings yet.\nTap the bookmark icon on a place to save it.',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final listing = listings[index];
                return ListingCard(
                  listing: listing,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListingDetailScreen(listing: listing),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

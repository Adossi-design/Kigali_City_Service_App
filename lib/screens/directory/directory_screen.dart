import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../listings/listing_detail_screen.dart';

// list of all available categories for filtering
const List<String> kCategories = [
  'All',
  'Café',
  'Hospital',
  'Park',
  'Restaurant',
  'Police Station',
  'Library',
  'Tourist Attraction',
];

// main directory screen — shows all listings with search and category filter
class DirectoryScreen extends ConsumerWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredListings = ref.watch(filteredListingsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back 👋',
                          style: GoogleFonts.dmSans(
                              color: AppTheme.muted, fontSize: 12)),
                      Text('Kigali City',
                          style: GoogleFonts.syne(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.white,
                          )),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // horizontal scrollable category chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: kCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = kCategories[index];
                  return CategoryChip(
                    label: cat,
                    isSelected: selectedCategory == cat,
                    onTap: () =>
                        ref.read(selectedCategoryProvider.notifier).state = cat,
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.navyCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.navyBorder),
                ),
                child: TextField(
                  onChanged: (v) =>
                      ref.read(searchQueryProvider.notifier).state = v,
                  style:
                      GoogleFonts.dmSans(color: AppTheme.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search for a service…',
                    hintStyle: GoogleFonts.dmSans(color: AppTheme.muted),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.muted),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // section label
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(title: 'Near You'),
            ),

            // listings list — shows loading, error, empty state, or listing cards
            Expanded(
              child: filteredListings.when(
                loading: () => const AppLoader(),
                error: (e, _) => Center(
                  child: Text('Error loading listings',
                      style: GoogleFonts.dmSans(color: AppTheme.muted)),
                ),
                data: (listings) {
                  if (listings.isEmpty) {
                    return const EmptyState(
                      emoji: '📍',
                      message:
                          'No listings found.\nTry a different search or category.',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final listing = listings[index];
                      return ListingCard(
                        listing: listing,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ListingDetailScreen(listing: listing),
                          ),
                        ),
                      );
                    },
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

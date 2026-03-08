import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'add_listing_screen.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myListings = ref.watch(myListingsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Listings',
                      style: GoogleFonts.syne(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.white,
                      )),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddListingScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      textStyle: GoogleFonts.syne(
                          fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: myListings.when(
                loading: () => const AppLoader(),
                error: (e, _) => Center(
                    child: Text('Error loading your listings',
                        style: GoogleFonts.dmSans(color: AppTheme.muted))),
                data: (listings) {
                  if (listings.isEmpty) {
                    return const EmptyState(
                      emoji: '📋',
                      message:
                          'You haven\'t added any listings yet.\nTap Add to get started!',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final listing = listings[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.navyCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.navyBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    listing.name,
                                    style: GoogleFonts.syne(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.gold.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    listing.category,
                                    style: GoogleFonts.dmSans(
                                      color: AppTheme.gold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${listing.address} · ${listing.contact}',
                              style: GoogleFonts.dmSans(
                                  color: AppTheme.muted, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              listing.description,
                              style: GoogleFonts.dmSans(
                                  color: AppTheme.muted,
                                  fontSize: 12,
                                  height: 1.4),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddListingScreen(
                                            existingListing: listing),
                                      ),
                                    ),
                                    icon: const Icon(Icons.edit,
                                        color: AppTheme.gold, size: 15),
                                    label: Text('Edit',
                                        style: GoogleFonts.dmSans(
                                            color: AppTheme.gold,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: AppTheme.gold, width: 0.5),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _confirmDelete(
                                        context, ref, listing.id),
                                    icon: const Icon(Icons.delete_outline,
                                        color: AppTheme.red, size: 15),
                                    label: Text('Delete',
                                        style: GoogleFonts.dmSans(
                                            color: AppTheme.red,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: AppTheme.red, width: 0.5),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.navyCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Listing',
            style: GoogleFonts.syne(
                color: AppTheme.white, fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete this listing?',
            style: GoogleFonts.dmSans(color: AppTheme.muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.dmSans(color: AppTheme.muted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(listingServiceProvider).deleteListing(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('🗑 Listing deleted', style: GoogleFonts.dmSans()),
                    backgroundColor: AppTheme.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

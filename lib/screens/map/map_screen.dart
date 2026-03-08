import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/listing_model.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../listings/listing_detail_screen.dart';
import '../directory/directory_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  ListingModel? _selectedListing;

  // Kigali center
  static const LatLng _kigaliCenter = LatLng(-1.9441, 30.0619);

  Set<Marker> _buildMarkers(List<ListingModel> listings) {
    return listings.map((listing) {
      return Marker(
        markerId: MarkerId(listing.id),
        position: LatLng(listing.latitude, listing.longitude),
        infoWindow: InfoWindow(
          title: listing.name,
          snippet: listing.category,
        ),
        onTap: () => setState(() => _selectedListing = listing),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final allListings = ref.watch(allListingsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Google Map
            allListings.when(
              loading: () => const AppLoader(),
              error: (e, _) => const Center(
                  child: Text('Map unavailable',
                      style: TextStyle(color: AppTheme.muted))),
              data: (listings) {
                final filtered = selectedCategory == 'All'
                    ? listings
                    : listings
                        .where((l) => l.category == selectedCategory)
                        .toList();
                return filtered.isEmpty
                    ? const Center(
                        child: Text('No listings to show on map',
                            style: TextStyle(color: AppTheme.muted)))
                    : GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: _kigaliCenter,
                          zoom: 13,
                        ),
                        markers: _buildMarkers(filtered),
                        onMapCreated: (c) => _mapController = c,
                        mapType: MapType.normal,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                      );
              },
            ),

            // Top title
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                decoration: BoxDecoration(
                  color: AppTheme.navy.withOpacity(0.95),
                  border: const Border(
                    bottom: BorderSide(color: AppTheme.navyBorder),
                  ),
                ),
                child: Text('Map View',
                    style: GoogleFonts.syne(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.white,
                    )),
              ),
            ),

            // Bottom card with filters
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  color: AppTheme.navy.withOpacity(0.97),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  border:
                      const Border(top: BorderSide(color: AppTheme.navyBorder)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    allListings.when(
                      data: (l) => Text(
                        '📍 ${l.length} places in Kigali',
                        style: GoogleFonts.syne(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.white,
                        ),
                      ),
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                    const SizedBox(height: 4),
                    Text('Tap a marker to view details',
                        style: GoogleFonts.dmSans(
                            color: AppTheme.muted, fontSize: 12)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: kCategories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = kCategories[index];
                          return CategoryChip(
                            label: cat,
                            isSelected:
                                ref.watch(selectedCategoryProvider) == cat,
                            onTap: () => ref
                                .read(selectedCategoryProvider.notifier)
                                .state = cat,
                          );
                        },
                      ),
                    ),

                    // Show selected listing
                    if (_selectedListing != null) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ListingDetailScreen(listing: _selectedListing!),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.navyCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.gold),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedListing!.name,
                                      style: GoogleFonts.syne(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.white,
                                      ),
                                    ),
                                    Text(
                                      _selectedListing!.category,
                                      style: GoogleFonts.dmSans(
                                          color: AppTheme.gold, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  color: AppTheme.gold, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/listing_service.dart';
import '../models/listing_model.dart';
import '../models/user_model.dart';

// Service Providers — creates a single instance of each service
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final listingServiceProvider =
    Provider<ListingService>((ref) => ListingService());

// Auth Providers — listens to Firebase Auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// fetches the current user's profile from Firestore
final currentUserProfileProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return ref.read(authServiceProvider).getUserProfile(user.uid);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Listing Providers — streams all listings from Firestore in real time
final allListingsProvider = StreamProvider<List<ListingModel>>((ref) {
  return ref.watch(listingServiceProvider).getListings();
});

// streams only the listings that belong to the current user
final myListingsProvider = StreamProvider<List<ListingModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      return ref.watch(listingServiceProvider).getMyListings(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Search & Filter State
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// filters listings based on search query and category
final filteredListingsProvider =
    Provider<AsyncValue<List<ListingModel>>>((ref) {
  final allListings = ref.watch(allListingsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final category = ref.watch(selectedCategoryProvider);

  return allListings.when(
    data: (listings) {
      var filtered = listings;
      if (category != 'All') {
        filtered = filtered.where((l) => l.category == category).toList();
      }
      if (query.isNotEmpty) {
        filtered = filtered
            .where((l) =>
                l.name.toLowerCase().contains(query) ||
                l.address.toLowerCase().contains(query))
            .toList();
      }
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

// Notification Preferences — controls toggle switches in settings screen
final locationNotificationsProvider = StateProvider<bool>((ref) => true);
final listingUpdatesNotificationsProvider = StateProvider<bool>((ref) => false);

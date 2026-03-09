import 'package:flutter_test/flutter_test.dart';
import 'package:kigali_city_services/models/listing_model.dart';

void main() {
  ListingModel listingWith(String category) => ListingModel(
        id: '1',
        name: 'Test Place',
        category: category,
        address: 'Kigali',
        contact: '+250 7XX XXX XXX',
        description: 'A test listing',
        latitude: -1.9441,
        longitude: 30.0619,
        createdBy: 'user-1',
        createdAt: DateTime(2024),
      );

  group('ListingModel.categoryEmoji', () {
    test('returns the matching emoji for a known category', () {
      expect(listingWith('Café').categoryEmoji, '☕');
      expect(listingWith('Hospital').categoryEmoji, '🏥');
      expect(listingWith('Park').categoryEmoji, '🌿');
    });

    test('falls back to a pin for an unknown category', () {
      expect(listingWith('Spaceport').categoryEmoji, '📍');
    });
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'listings';

  // Stream all listings
  Stream<List<ListingModel>> getListings() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ListingModel.fromFirestore(doc))
            .toList());
  }

  // Stream listings by current user
  Stream<List<ListingModel>> getMyListings(String uid) {
    return _firestore
        .collection(_collection)
        .where('createdBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ListingModel.fromFirestore(doc))
            .toList());
  }

  // Create listing
  Future<void> createListing(ListingModel listing) async {
    await _firestore.collection(_collection).add(listing.toFirestore());
  }

  // Update listing
  Future<void> updateListing(ListingModel listing) async {
    await _firestore
        .collection(_collection)
        .doc(listing.id)
        .update(listing.toFirestore());
  }

  // Delete listing
  Future<void> deleteListing(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Get single listing
  Future<ListingModel?> getListing(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) return ListingModel.fromFirestore(doc);
    return null;
  }
}

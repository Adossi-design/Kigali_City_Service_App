import 'package:cloud_firestore/cloud_firestore.dart';

class BookmarkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'bookmarks';

  // deterministic id so a listing can only be bookmarked once per user
  String _docId(String uid, String listingId) => '${uid}_$listingId';

  // Stream the set of listing ids the user has saved
  Stream<Set<String>> getBookmarkedListingIds(String uid) {
    return _firestore
        .collection(_collection)
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data()['listingId'] as String)
            .toSet());
  }

  // Save a listing
  Future<void> addBookmark(String uid, String listingId) async {
    await _firestore.collection(_collection).doc(_docId(uid, listingId)).set({
      'ownerId': uid,
      'listingId': listingId,
      'createdAt': Timestamp.now(),
    });
  }

  // Remove a saved listing
  Future<void> removeBookmark(String uid, String listingId) async {
    await _firestore
        .collection(_collection)
        .doc(_docId(uid, listingId))
        .delete();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

// Model for a signed-in user
class UserModel {
  final String uid;
  final String name;
  final String email;
  final bool emailVerified;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.emailVerified,
    required this.createdAt,
  });

  // converts Firestore document into a UserModel object
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      emailVerified: data['emailVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // converts UserModel into a map to save to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'emailVerified': emailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

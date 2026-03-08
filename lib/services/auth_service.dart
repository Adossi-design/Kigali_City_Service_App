import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign Up
  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Send verification email
    await credential.user?.sendEmailVerification();

    // Create user profile in Firestore
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'email': email,
      'emailVerified': false,
      'createdAt': Timestamp.now(),
    });

    return credential;
  }

  // Sign In
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Check email verification
    if (!credential.user!.emailVerified) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Please verify your email before signing in.',
      );
    }

    return credential;
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // Get user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) return UserModel.fromFirestore(doc);
    return null;
  }

  // Update email verified status
  Future<void> updateEmailVerified(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'emailVerified': true,
    });
  }
}

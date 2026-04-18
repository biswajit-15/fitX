import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ⚠️ serverClientId is your OAuth Web Client ID (not a secret, but avoid committing in open-source projects)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
    '171162071360-vfh5kgpvmo0m6sg0qb9joikldjp5vjqd.apps.googleusercontent.com',
  );

  /// Current signed-in user (null if not logged in)
  User? get currentUser => _auth.currentUser;

  /// Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Google Sign-In ───────────────────────────────────────────────────────

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
      await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint("User cancelled login");
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;



      final AuthCredential credential =
      GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );


      final userCredential =
      await _auth.signInWithCredential(credential);


      return userCredential;
    } catch (e, stack) {
      debugPrint("❌ ERROR: ${e.toString()}");
      debugPrint("❌ STACK: $stack");
      return null;
    }
  }
  // ─── Email / Password Login ───────────────────────────────────────────────

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),   // FIX: trim here too, not just in signUp
        password: password.trim(),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapError(e)); // FIX: throw Exception, not raw String
    }
  }

  // ─── Sign Up ──────────────────────────────────────────────────────────────

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (userCredential.user != null &&
          !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapError(e)); // FIX: throw Exception, not raw String
    }
  }

  // ─── Forgot Password ──────────────────────────────────────────────────────

  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapError(e)); // FIX: throw Exception, not raw String
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    // FIX: wrap Google sign-out in try-catch — it throws if user never
    // signed in with Google, which would block Firebase sign-out
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint("Google Sign-Out skipped: $e");
    }
    await _auth.signOut();
  }

  // ─── Error Mapping ────────────────────────────────────────────────────────

  // FIX: returns String (message only) — callers wrap with Exception()
  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'operation-not-allowed':
        return 'Login method not enabled. Contact admin.';
      case 'network-request-failed':
        return 'No internet connection. Check your network.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
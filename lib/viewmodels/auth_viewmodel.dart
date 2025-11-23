import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanus_academy/models/app_user.dart';
import 'package:lanus_academy/services/auth_service.dart';
import 'package:lanus_academy/services/firestore_services.dart';

class AuthNotifier extends AsyncNotifier<AppUser?> {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  FutureOr<AppUser?> build() async {
    // runs automatically when provider is first read
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    final appUser = await FirestoreService.getUserById(user.uid);
    return appUser;
  }

  /// SIGN UP — only creates Firebase user, not Firestore user.
  Future<bool> signUp(String email, String password) async {
    state = const AsyncLoading();

    try {
      final UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Do NOT create Firestore user here
      // Just return and navigate to onboarding
      if (credential.user == null) {
        state = AsyncData(null);
        return false; // <-- never return null
      }

      state = AsyncData(null);

      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  //login with email and password
  Future<bool> signIn(String email, String password) async {
    state = const AsyncLoading();

    try {
      final UserCredential credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      final appUser = await FirestoreService.getUserById(credential.user!.uid);
      state = AsyncData(appUser);
      return true;
    } catch (err, st) {
      state = AsyncError(err, st);
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      state = const AsyncLoading();

      // 1️⃣ Sign in with Google (this returns Firebase User?)
      final user = await AuthService.signInWithGoogle();

      if (user == null) {
        state = AsyncError("Sign-in failed", StackTrace.current);
        return false; // ❌ Fix: return false for failure
      }

      // 2️⃣ Check AppUser in Firestore
      final appUser = await FirestoreService.getUserById(user.uid);

      if (appUser == null) {
        // User exists in Firebase but NOT in Firestore → needs onboarding
        state = const AsyncData(null);
        return true;
      }

      // 3️⃣ Normal existing user → set authenticated state
      state = AsyncData(appUser);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    state = const AsyncData(null);
  }
}

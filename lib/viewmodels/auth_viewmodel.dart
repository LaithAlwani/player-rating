import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<String> signUp(String email, String password) async {
    try {
      final UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user == null) {
        state = AsyncData(null);
        return "حدث خطأ، الرجاء المحاولة مرة أخرى"; // Generic error
      }

      // Create an empty AppUser object locally (do not save to Firestore yet)
      state = AsyncData(
        AppUser(
          uid: credential.user!.uid,
          displayName: "",
          displayNameLower: "",
          email: email,
          position: "",
          role: "user",
        ),
      );

      return "success"; // Success indicator
    } on FirebaseAuthException catch (e) {
      state = AsyncData(null);

      // Handle specific Firebase errors
      switch (e.code) {
        case "email-already-in-use":
          return "هذا البريد الإلكتروني لمستخدم فعال";
        case "invalid-email":
          return "البريد الإلكتروني غير صالح";
        case "operation-not-allowed":
          return "عملية التسجيل غير مسموح بها حالياً";
        case "weak-password":
          return "كلمة المرور ضعيفة جدًا";
        default:
          return "حدث خطأ غير معروف، الرجاء المحاولة مرة أخرى";
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      return "حدث خطأ، الرجاء المحاولة مرة أخرى";
    }
  }

  //login with email and password
  Future<String> signIn(String email, String password) async {
    try {
      final UserCredential credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final firebaseUser = credential.user;

      // 🔥 Update lastLogin timestamp in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser!.uid)
          .update({'lastLogin': FieldValue.serverTimestamp()});

      // Fetch user from Firestore
      final appUser = await FirestoreService.getUserById(firebaseUser.uid);
      state = AsyncData(appUser);

      return "success"; // Sign-in successful
    } on FirebaseAuthException catch (e) {
      state = AsyncData(null);
      // Handle Firebase sign-in errors with Arabic messages
      switch (e.code) {
        case "invalid-credential":
          return "بيانات الاعتماد غير صالحة";
        case "invalid-email":
          return "البريد الإلكتروني غير صالح";
        case "user-disabled":
          return "تم تعطيل حساب المستخدم";
        case "user-not-found":
          return "المستخدم غير موجود";
        case "wrong-password":
          return "كلمة المرور غير صحيحة";
        case "too-many-requests":
          return "عدد كبير من المحاولات، حاول لاحقًا";
        default:
          return "حدث خطأ غير معروف، الرجاء المحاولة مرة أخرى";
      }
    } catch (err, st) {
      state = AsyncError(err, st);
      return "حدث خطأ، الرجاء المحاولة مرة أخرى";
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      // state = const AsyncLoading();

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
        state = AsyncData(
          AppUser(
            uid: user.uid,
            displayName: "",
            displayNameLower: "",
            email: user.email ?? "",
            position: "",
            role: "user",
          ),
        );
        return true;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'lastLogin': FieldValue.serverTimestamp()},
      );

      // 3️⃣ Normal existing user → set authenticated state
      state = AsyncData(appUser);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  // Sign out
  Future<String> signOut() async {
    try {
      await _firebaseAuth.signOut();
      state = const AsyncData(null);
      return "success"; // sign-out successful
    } catch (e) {
      return "حدث خطأ أثناء تسجيل الخروج";
    }
  }
}

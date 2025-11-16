import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:player_rating/models/app_user.dart';
import 'package:player_rating/services/firestore_services.dart';

final authProvider = StreamProvider.autoDispose<AppUser?>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    print("🔔 authStateChanges emission → ${user?.uid} at ${DateTime.now()}");
    if (user == null) {
      return null;
    }
    final appUser = await FirestoreService.getUserById(user.uid);
    if (appUser == null) {
      print("❌ No AppUser found for UID: ${user.uid}");
      await FirestoreService.createUser(
        AppUser(
          uid: user.uid,
          email: user.email ?? "",
          displayName: user.displayName ?? "",
          role: "user",
          photoUrl: user.photoURL ?? "",
        ),
      );
      final appUser = await FirestoreService.getUserById(user.uid);
      return appUser;
    }
    return appUser;
  });
});

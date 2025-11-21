import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanus_academy/models/app_user.dart';
import 'package:lanus_academy/services/firestore_services.dart';

final authProvider = StreamProvider.autoDispose<AppUser?>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    print("🔔 authStateChanges emission → ${user?.uid} at ${DateTime.now()}");
    if (user == null) {
      return null;
    }
    final appUser = await FirestoreService.getUserById(user.uid);
    if (appUser == null && user.displayName != null) {
      print("❌ No AppUser found for UID: ${user.uid}");
      await FirestoreService.createUser(
        AppUser(
          uid: user.uid,
          email: user.email ?? "",
          displayName: user.displayName ?? "",
          displayNameLower:(user.displayName ?? "").toLowerCase() ,
          role: "user",
          photoUrl: user.photoURL ?? "",
        ),
      );
      final appUser = await FirestoreService.getUserById(user.uid);
      print("✅ Created new AppUser for UID: ${user.displayName}");
      return appUser;
    }
    return appUser;
  });
});

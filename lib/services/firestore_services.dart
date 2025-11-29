import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lanus_academy/models/app_user.dart';

class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;

  /// Users collection with typed converter
  static final _userRef = _firestore
      .collection("users")
      .withConverter<AppUser>(
        fromFirestore: AppUser.fromFirestore,
        toFirestore: (AppUser user, _) => user.toFirestore(),
      );

  /// Create or overwrite a user
  static Future<void> createUser(AppUser user) async {
    try {
      await _userRef.doc(user.uid).set(user);
    } catch (e) {
      debugPrint("❌ Error creating user: $e");
      rethrow;
    }
  }

  /// Get a user by their UID
  static Future<AppUser?> getUserById(String uid) async {
    debugPrint("🔔 Fetching user with UID: $uid");
    try {
      final userDoc = await _userRef.doc(uid).get();
      if (!userDoc.exists) return null;
      return userDoc.data();
    } catch (e) {
      debugPrint("❌ Error fetching user: $e");
      return null;
    }
  }

  /// Update user partially
  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _userRef.doc(uid).update(data);
    } catch (e) {
      debugPrint("❌ Error updating user: $e");
      rethrow;
    }
  }

  /// Delete user document
  static Future<bool> deleteUser(String uid) async {
    try {
      await _userRef.doc(uid).delete();
      return true;
    } catch (e) {
      debugPrint("❌ Error deleting user: $e");
      return false;
    }
  }

  static Stream<List<AppUser>> fethcAllUsers() {
    //where rols is not admin
    return _userRef
        .where("role", isNotEqualTo: "admin")
        .orderBy("rating", descending: true)
        .snapshots()
        .map(
          (querySnapshot) =>
              querySnapshot.docs.map((doc) => doc.data()).toList(),
        );
  }

  static Future<QuerySnapshot<AppUser>> fetchUsersPage({
    DocumentSnapshot<AppUser>? lastDoc,
    int limit = 10,
  }) {
    Query<AppUser> query = _userRef
        .where("role", isNotEqualTo: "admin") // server-side filtering
        .orderBy("role")
        .orderBy("points", descending: true)
        .orderBy("uid")
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }
    final test = query.get();
    return test;
  }

  static Future<QuerySnapshot<AppUser>> searchUsersPage({
    required String queryText,
    DocumentSnapshot<AppUser>? lastDoc,
    int limit = 10,
  }) {
    print("Search users with query: $queryText");
    print("Search users last doc: ${lastDoc?.data()}");
    try {
      Query<AppUser> query = _userRef
          .orderBy("displayNameLower")
          .startAt([queryText.trim()])
          .endAt(["${queryText.trim()}\uf8ff"])
          .limit(limit);

      // if (lastDoc != null) {
      //   query = query.startAfterDocument(lastDoc);
      // }

      return query.get();
    } catch (e) {
      debugPrint("❌ Error in searchUsersPage: $e");
      rethrow;
    }
  }

  // Stream of user updates (for real-time profile changes)
  static Stream<AppUser?> listenToUser(String uid) {
    return _userRef.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return snapshot.data();
    });
  }
}

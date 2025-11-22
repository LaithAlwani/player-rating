import 'package:cloud_firestore/cloud_firestore.dart';
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
      print("❌ Error creating user: $e");
      rethrow;
    }
  }

  /// Get a user by their UID
  static Future<AppUser?> getUserById(String uid) async {
    print("🔔 Fetching user with UID: $uid");
    try {
      final userDoc = await _userRef.doc(uid).get();
      if (!userDoc.exists) return null;
      return userDoc.data();
    } catch (e) {
      print("❌ Error fetching user: $e");
      return null;
    }
  }

  /// Update user partially
  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _userRef.doc(uid).update(data);
    } catch (e) {
      print("❌ Error updating user: $e");
      rethrow;
    }
  }

  /// Delete user document
  static Future<void> deleteUser(String uid) async {
    try {
      await _userRef.doc(uid).delete();
    } catch (e) {
      print("❌ Error deleting user: $e");
      rethrow;
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
    int limit = 20,
  }) {
    Query<AppUser> query = _userRef
        .where("role", isNotEqualTo: "admin")
        .orderBy("role")
        .orderBy("rating", descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    return query.get();
  }

  static Future<QuerySnapshot<AppUser>> searchUsersPage({
    required String queryText,
    DocumentSnapshot<AppUser>? lastDoc,
    int limit = 10,
  }) {
    Query<AppUser> query = _userRef
        .where("role", isNotEqualTo: "admin")
        .orderBy("displayNameLower")
        .startAt([queryText])
        .endAt(["$queryText\uf8ff"])
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    return query.get();
  }

  static Stream<List<AppUser>> searchUsersByName(String username) {
    return _userRef
        // .where("displayName", isGreaterThanOrEqualTo: username)
        .where("role", isNotEqualTo: "admin")
        .orderBy("displayNameLower")
        .startAt([username])
        .endAt(["$username\uf8ff"])
        .limit(10)
        .snapshots()
        .map(
          (querySnapshot) =>
              querySnapshot.docs.map((doc) => doc.data()).toList(),
        );
  }

  /// Stream of user updates (for real-time profile changes)
  static Stream<AppUser?> streamUser(String uid) {
    return _userRef.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return snapshot.data();
    });
  }

  // static final recipeRef = FirebaseFirestore.instance
  //     .collection("recipes")
  //     .withConverter(
  //       fromFirestore: Recipe.fromFirestore,
  //       toFirestore: (Recipe recipe, _) => recipe.toMap(),
  //     );

  // static Future<List<Recipe>> getRecipesByCreatedBy(String uid) async {
  //   final snapshot = await recipeRef
  //       .where('created_by', isEqualTo: uid)
  //       .orderBy('created_at', descending: true)
  //       .get();

  //   return snapshot.docs.map((doc) => doc.data()).toList();
  // }
}

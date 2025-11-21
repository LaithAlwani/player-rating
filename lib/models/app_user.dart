import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  AppUser({
    required this.uid,
    required this.displayName,
    required this.displayNameLower,
    required this.email,
    this.rating = 0,
    this.photoUrl,
    this.isVerified = false,
    this.role = "user",
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) : createdAt = createdAt ?? Timestamp.now(),
       updatedAt = updatedAt ?? Timestamp.now();
  final String uid;
  final String displayName;
  final String displayNameLower;
  final String email;
  final String? photoUrl;
  final int? rating;
  final bool isVerified;
  final String role;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  // ---------- Serialization ----------

  factory AppUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;

    return AppUser(
      uid: snapshot.id,
      displayName: data['displayName'],
      displayNameLower: data['displayNameLower'],
      email: data['email'],
      photoUrl: data['photoUrl'],
      rating: data['rating'],
      isVerified: data['isVerified'] ?? false,
      role: data['role'] ?? 'user',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'displayName': displayName,
      'displayNameLower': displayNameLower,
      'email': email,
      'photoUrl': photoUrl,
      'rating': rating,
      'isVerified': isVerified,
      'role': role,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  AppUser copyWith({
    String? uid,
    String? displayName,
    String? displayNameLower,
    String? email,
    String? photoUrl,
    int? rating,
    bool? isVerified,
    String? role,
    Timestamp? updatedAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      displayNameLower: displayNameLower ?? this.displayNameLower,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      rating: rating ?? this.rating,
      isVerified: isVerified ?? this.isVerified,
      role: role ?? this.role,
      createdAt: createdAt,
      updatedAt: updatedAt ?? Timestamp.now(),
    );
  }
}

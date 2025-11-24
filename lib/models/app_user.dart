import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanus_academy/models/player_stats.dart';

class AppUser {
  AppUser({
    required this.uid,
    required this.displayName,
    required this.displayNameLower,
    required this.email,
    required this.position,
    this.rating = 0,
    this.photoUrl,
    this.isVerified = false,
    this.role = "user",
    this.stats,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? lastLogin,
  }) : createdAt = createdAt ?? Timestamp.now(),
       updatedAt = updatedAt ?? Timestamp.now(),
       lastLogin = lastLogin ?? Timestamp.now();
  final String uid;
  final String displayName;
  final String displayNameLower;
  final String position;
  final String email;
  final String? photoUrl;
  final int? rating;
  final bool isVerified;
  final String role;
  final PlayerStats? stats;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final Timestamp lastLogin;

  bool get isGoalkeeper => position == "GK";

  int get overallRating {
    if (stats == null) return 0;
    return stats!.overall; // already int
  }

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
      position: data['position'],
      email: data['email'],
      photoUrl: data['photoUrl'],
      rating: data['rating'],
      isVerified: data['isVerified'] ?? false,
      role: data['role'] ?? 'user',
      stats: PlayerStats.fromFirestore(data['stats']),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      lastLogin: data['lastLogin'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'displayName': displayName,
      'displayNameLower': displayNameLower,
      'position': position,
      'email': email,
      'photoUrl': photoUrl,
      'rating': rating,
      'isVerified': isVerified,
      'role': role,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastLogin': lastLogin,
      if (stats != null) 'stats': stats!.toFirestore(),
    };
  }

  AppUser copyWith({
    String? uid,
    String? displayName,
    String? displayNameLower,
    String? position,
    String? email,
    String? photoUrl,
    int? rating,
    bool? isVerified,
    String? role,
    PlayerStats? stats,
    Timestamp? updatedAt,
    Timestamp? lastLogin,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      displayNameLower: displayNameLower ?? this.displayNameLower,
      email: email ?? this.email,
      position: position ?? this.position,
      photoUrl: photoUrl ?? this.photoUrl,
      rating: rating ?? this.rating,
      isVerified: isVerified ?? this.isVerified,
      role: role ?? this.role,
      createdAt: createdAt,
      stats: stats ?? this.stats,
      updatedAt: updatedAt ?? Timestamp.now(),
      lastLogin: lastLogin ?? Timestamp.now(),
    );
  }
}

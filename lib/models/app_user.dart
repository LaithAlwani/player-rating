import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanus_academy/models/player_stats.dart';

class AppUser {
  AppUser({
    required this.uid,
    required this.displayName,
    required this.displayNameLower,
    required this.email,
    required this.position,
    this.photoUrl,
    this.isVerified = false,
    this.role = "user",
    this.stats,
    this.points,
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
  final bool isVerified;
  final String role;
  final int? points;
  final PlayerStats? stats;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final Timestamp lastLogin;

  bool get isGoalkeeper => position == "GK";

  int get overallRating => stats?.overall ?? 0;

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
      isVerified: data['isVerified'] ?? false,
      role: data['role'] ?? 'user',
      points: data['points'] ?? 0,
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
      'isVerified': isVerified,
      'role': role,
      'points': points,
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
    bool? isVerified,
    String? role,
    int? points,
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
      isVerified: isVerified ?? this.isVerified,
      role: role ?? this.role,
      points: points ?? this.points,
      createdAt: createdAt,
      stats: stats ?? this.stats,
      updatedAt: updatedAt ?? Timestamp.now(),
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  AppUser merge(Map<String, dynamic> data) {
    return copyWith(
      uid: data["uid"],
      displayName: data['displayName'],
      displayNameLower: data['displayNameLower'],
      position: data['position'],
      email: data['email'],
      photoUrl: data['photoUrl'],
      isVerified: data['isVerified'] ?? false,
      role: data['role'] ?? 'user',
      points: data['points'] ?? 0,
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      lastLogin: data['lastLogin'] ?? Timestamp.now(),
      stats: data['stats'] != null ? stats!.merge(data['stats']) : stats,
    );
  }

  @override
  String toString() {
    return 'AppUser(uid: $uid, displayName: $displayName, role: $role, email: $email)';
  }
}

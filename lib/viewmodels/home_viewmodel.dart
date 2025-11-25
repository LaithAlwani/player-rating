import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lanus_academy/models/app_user.dart';
import 'package:lanus_academy/models/field_player_stats.dart';
import 'package:lanus_academy/models/goal_keeper_stats.dart';
import 'package:lanus_academy/models/player_stats.dart';
import 'package:lanus_academy/services/firestore_services.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel();
  List<AppUser> players = [];
  DocumentSnapshot<AppUser>? lastDoc;
  bool isLoading = false;
  bool hasMore = true;
  String currentSearch = "";

  final Map<String, StreamSubscription<AppUser?>> _listeners = {};

  int pageSize = 10;

  Future<void> loadInitial() async {
    isLoading = true;
    notifyListeners();

    players.clear();
    lastDoc = null;
    hasMore = true;

    final snapshot = await FirestoreService.fetchUsersPage(limit: 20);
    players = snapshot.docs.map((d) => d.data()).toList();
    if (snapshot.docs.isNotEmpty) lastDoc = snapshot.docs.last;
    if (snapshot.docs.length < 20) hasMore = false;

    // Attach per-user listeners
    for (final player in players) {
      _listenToPlayer(player.uid);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    notifyListeners();

    QuerySnapshot<AppUser> snapshot;

    if (currentSearch.isEmpty) {
      snapshot = await FirestoreService.fetchUsersPage(
        lastDoc: lastDoc,
        limit: pageSize,
      );
    } else {
      snapshot = await FirestoreService.searchUsersPage(
        queryText: currentSearch,
        lastDoc: lastDoc,
        limit: pageSize,
      );
    }
    final newPlayers = snapshot.docs.map((d) => d.data()).toList();
    if (snapshot.docs.isNotEmpty) {
      lastDoc = snapshot.docs.last;
      players.addAll(snapshot.docs.map((d) => d.data()));
    }

    if (snapshot.docs.length < pageSize) {
      hasMore = false;
    }

    // Attach listeners for new users
    for (final player in newPlayers) {
      _listenToPlayer(player.uid);
    }

    isLoading = false;
    notifyListeners();
  }

  void updateLocalPlayer(AppUser updatedUser) {
    final index = players.indexWhere((p) => p.uid == updatedUser.uid);
    if (index != -1) {
      players[index] = updatedUser;
      notifyListeners(); // <-- inside the ChangeNotifier
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      // Convert nested objects to Map for Firestore
      final firestoreData = <String, dynamic>{};
      data.forEach((key, value) {
        if (value is PlayerStats ||
            value is FieldPlayerStats ||
            value is GoalkeeperStats) {
          firestoreData[key] = (value as dynamic).toFirestore();
        } else {
          firestoreData[key] = value;
        }
      });

      await FirestoreService.updateUser(uid, firestoreData);

      // Update local list
      final index = players.indexWhere((p) => p.uid == uid);
      if (index == -1) return;

      final oldUser = players[index];

      // Reconstruct PlayerStats from Map before merging
      final newStats = data['stats'] is PlayerStats
          ? data['stats']
          : PlayerStats.fromFirestore(data['stats']);

      final updatedUser = oldUser.copyWith(
        stats: newStats,
        displayName: data['displayName'] ?? oldUser.displayName,
        photoUrl: data['photoUrl'] ?? oldUser.photoUrl,
        // add other fields as needed
      );

      players[index] = updatedUser;
      notifyListeners();
    } catch (e) {
      print("❌ Error updating user: $e");
      rethrow;
    }
  }

  /// Listen to a single user
  void _listenToPlayer(String uid) {
    if (_listeners.containsKey(uid)) return;

    final sub = FirestoreService.listenToUser(uid).listen((updatedUser) {
      if (updatedUser == null) return;

      final index = players.indexWhere((p) => p.uid == uid);
      if (index != -1) {
        players[index] = updatedUser;
        players.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        notifyListeners();
      }
    });

    _listeners[uid] = sub;
  }

  Future<void> searchPlayers(String query) async {
    currentSearch = query.trim().toLowerCase();
    await loadInitial();
  }

  Future<void> refreshPlayers() async {
    currentSearch = "";
    await loadInitial();
  }

  /// Dispose all listeners
  @override
  void dispose() {
    for (final sub in _listeners.values) {
      sub.cancel();
    }
    super.dispose();
  }
}

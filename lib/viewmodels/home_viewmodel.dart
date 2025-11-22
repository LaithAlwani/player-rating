import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lanus_academy/models/app_user.dart';
import 'package:lanus_academy/services/firestore_services.dart';

class HomeViewModel extends ChangeNotifier {
  List<AppUser> players = [];
  DocumentSnapshot<AppUser>? lastDoc;
  bool isLoading = false;
  bool hasMore = true;
  String currentSearch = "";

  int pageSize = 10;

  Future<void> loadInitial() async {
    players.clear();
    lastDoc = null;
    hasMore = true;
    await loadMore();
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
    if (snapshot.docs.isNotEmpty) {
      lastDoc = snapshot.docs.last;
      players.addAll(snapshot.docs.map((d) => d.data()));
    }

    if (snapshot.docs.length < pageSize) {
      hasMore = false;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> searchPlayers(String query) async {
    currentSearch = query.trim().toLowerCase();
    await loadInitial();
  }

  Future<void> refreshPlayers() async {
    currentSearch = "";
    await loadInitial();
  }
}

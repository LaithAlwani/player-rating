import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lanus_academy/models/app_user.dart';
import 'package:lanus_academy/models/field_player_stats.dart';
import 'package:lanus_academy/models/goal_keeper_stats.dart';
import 'package:lanus_academy/models/player_stats.dart';
import 'package:lanus_academy/services/firestore_services.dart';
import 'package:lanus_academy/viewmodels/home_viewmodel.dart';

final homeViewModelProvider =
    StateNotifierProvider.autoDispose<HomeViewModelNotifier, HomeState>((ref) {
      return HomeViewModelNotifier();
    });

class HomeState {
  final List<AppUser> players;
  final bool isLoading;
  final bool hasMore;
  final DocumentSnapshot<AppUser>? lastDoc;
  final String currentSearch;

  const HomeState({
    this.players = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.lastDoc,
    this.currentSearch = "",
  });

  HomeState copyWith({
    List<AppUser>? players,
    bool? isLoading,
    bool? hasMore,
    DocumentSnapshot<AppUser>? lastDoc,
    String? currentSearch,
  }) {
    return HomeState(
      players: players ?? this.players,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      lastDoc: lastDoc ?? this.lastDoc,
      currentSearch: currentSearch ?? this.currentSearch,
    );
  }
}

class HomeViewModelNotifier extends StateNotifier<HomeState> {
  HomeViewModelNotifier() : super(const HomeState()) {
    loadInitial();
  }

  /// Load first page
  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      players: [],
      lastDoc: null,
      hasMore: true,
    );

    final snapshot = await FirestoreService.fetchUsersPage(limit: 20);

    final playersList = snapshot.docs.map((d) => d.data()).toList();
    final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    final hasMore = snapshot.docs.length >= 20;

    state = state.copyWith(
      players: playersList,
      lastDoc: lastDoc,
      hasMore: hasMore,
      isLoading: false,
    );
  }

  /// Load more for pagination
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    QuerySnapshot<AppUser> snapshot;

    if (state.currentSearch.isEmpty) {
      snapshot = await FirestoreService.fetchUsersPage(
        lastDoc: state.lastDoc,
        limit: 20,
      );
    } else {
      snapshot = await FirestoreService.searchUsersPage(
        queryText: state.currentSearch,
        lastDoc: state.lastDoc,
        limit: 20,
      );
    }

    final newPlayers = snapshot.docs.map((d) => d.data()).toList();
    final lastDoc = snapshot.docs.isNotEmpty
        ? snapshot.docs.last
        : state.lastDoc;
    final hasMore = snapshot.docs.length >= 20;

    state = state.copyWith(
      players: [...state.players, ...newPlayers],
      lastDoc: lastDoc,
      hasMore: hasMore,
      isLoading: false,
    );
  }

  Future<void> fetchPlayerById(String uid) async {
    final existingIndex = state.players.indexWhere((p) => p.uid == uid);
    if (existingIndex != -1) return; // Already loaded

    try {
      final doc = await FirestoreService.getUserById(uid);
      final player = doc;

      if (player != null) {
        final updatedPlayers = [...state.players, player];
        state = state.copyWith(players: updatedPlayers);
      }
    } catch (e) {
      print("❌ Error fetching player $uid: $e");
    }
  }

  /// Search
  Future<void> searchPlayers(String query) async {
    state = state.copyWith(currentSearch: query.trim().toLowerCase());
    await loadInitial();
  }

  /// Refresh all players
  Future<void> refreshPlayers() async {
    state = state.copyWith(currentSearch: "");
    await loadInitial();
  }

  /// Update a player locally after editing
  void updateLocalPlayer(AppUser updatedUser) {
    final index = state.players.indexWhere((p) => p.uid == updatedUser.uid);
    if (index != -1) {
      final updatedPlayers = [...state.players];
      updatedPlayers[index] = updatedUser;
      state = state.copyWith(players: updatedPlayers);
    }
  }

  /// Update player in Firestore and locally
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      // Convert nested stats objects to Map
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

      // Update locally
      final index = state.players.indexWhere((p) => p.uid == uid);
      if (index != -1) {
        final oldUser = state.players[index];

        final newStats = data['stats'] is PlayerStats
            ? data['stats']
            : PlayerStats.fromFirestore(data['stats']);

        final updatedUser = oldUser.copyWith(
          stats: newStats,
          displayName: data['displayName'] ?? oldUser.displayName,
          photoUrl: data['photoUrl'] ?? oldUser.photoUrl,
        );

        final updatedPlayers = [...state.players];
        updatedPlayers[index] = updatedUser;
        state = state.copyWith(players: updatedPlayers);
      }
    } catch (e) {
      print("❌ Error updating user: $e");
      rethrow;
    }
  }
}

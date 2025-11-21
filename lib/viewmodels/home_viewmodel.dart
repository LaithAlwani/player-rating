import 'package:flutter/material.dart';
import 'package:lanus_academy/models/app_user.dart';
import 'package:lanus_academy/services/firestore_services.dart';

class HomeViewmodel extends ChangeNotifier {
  Stream<List<AppUser>> playersStream = FirestoreService.fethcAllUsers();

  void searchPlayers(String query) {
    if (query.isEmpty) {
      playersStream = FirestoreService.fethcAllUsers();
    } else {
      playersStream = FirestoreService.searchUsersByName(query);
    }
    notifyListeners();
  }

  void refreshPlayers() {
    playersStream = FirestoreService.fethcAllUsers();
    notifyListeners();
  }
}

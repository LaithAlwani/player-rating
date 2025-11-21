import 'package:flutter/material.dart';
import 'package:lanus_academy/provider/auth_provider.dart';
import 'package:lanus_academy/screens/profile.dart';
import 'package:lanus_academy/services/auth_service.dart';
import 'package:lanus_academy/viewmodels/home_viewmodel.dart';
import 'package:lanus_academy/models/app_user.dart';
import 'package:lanus_academy/widgets/player_tile.dart';
import 'package:lanus_academy/widgets/confirm_delete_dialog.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewmodel(),
      child: Consumer<HomeViewmodel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              leading: Image.asset("./assets/logo.png"),
              title: Text("قائمة اللاعبين"),
              actions: [
                IconButton(
                  onPressed: () async {
                    await AuthService.signOut();
                  },
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  child: SearchBar(
                    leading: Icon(Icons.search),
                    hintText: "ابحث عن اسم لاعب...",
                    onSubmitted: vm.searchPlayers,
                  ),
                ),

                Expanded(
                  child: StreamBuilder<List<AppUser>>(
                    stream: vm.playersStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final players = snapshot.data!;

                      return RefreshIndicator(
                        onRefresh: () async => vm.refreshPlayers(),
                        child: ListView.builder(
                          itemCount: players.length,
                          itemBuilder: (context, index) {
                            final player = players[index];

                            return Dismissible(
                              key: Key(player.uid),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (dir) async {
                                return await showConfirmDeleteDialog(
                                  context,
                                  player.displayName,
                                );
                              },
                              child: PlayerTile(
                                player: player,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Profile(user: player),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

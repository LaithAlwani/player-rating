import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanus_academy/provider/auth_provider.dart';
import 'package:lanus_academy/provider/home_view_model_provider.dart';
import 'package:lanus_academy/screens/profile.dart';

import 'package:lanus_academy/widgets/player_tile.dart';
import 'package:lanus_academy/widgets/confirm_delete_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final vm = ref.read(homeViewModelProvider.notifier);
      final state = ref.read(homeViewModelProvider);
      if (!state.isLoading &&
          state.hasMore &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
        vm.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final homeVM = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/logo.png'),
        ),
        centerTitle: true,
        title: const Text("قائمة اللاعبين"),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (state.isLoading && state.players.isEmpty) {
            // First load
            return const Center(child: CircularProgressIndicator());
          }

          // Loaded & has players
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.only(bottom: 16, right: 24, left: 24),
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 1),
                    ),
                  ),
                  child: SearchBar(
                    leading: const Icon(Icons.search),
                    hintText: "ابحث عن اسم لاعب...",
                    backgroundColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    shadowColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    overlayColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    onSubmitted: (query) => homeVM.searchPlayers(query),
                  ),
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => homeVM.refreshPlayers(),
                  child: !state.isLoading && state.players.isEmpty
                      ?
                        // Finished loading but still empty
                        const Center(child: Text("لا يوجد لاعبين"))
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount:
                              state.players.length + (state.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.players.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final player = state.players[index];

                            return Dismissible(
                              key: Key(player.uid),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (dir) async {
                                final shouldDelete =
                                    await showConfirmDeleteDialog(
                                      context,
                                      player.displayName,
                                      player.uid,
                                    );
                                if (shouldDelete) {
                                  await homeVM.removePlayer(player.uid);
                                }
                                return shouldDelete;
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

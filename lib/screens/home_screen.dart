import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Consumer;
import 'package:lanus_academy/provider/auth_provider.dart';
import 'package:lanus_academy/screens/profile.dart';
import 'package:lanus_academy/services/auth_service.dart';
import 'package:lanus_academy/viewmodels/home_viewmodel.dart';
import 'package:lanus_academy/models/app_user.dart';
import 'package:lanus_academy/widgets/player_tile.dart';
import 'package:lanus_academy/widgets/confirm_delete_dialog.dart';
import 'package:provider/provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final HomeViewModel vm;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    vm = HomeViewModel();
    vm.loadInitial();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        vm.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return ChangeNotifierProvider<HomeViewModel>.value(
      value: vm,
      child: Consumer<HomeViewModel>(
        builder: (context, vm, _) {
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
            body: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
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
                      onSubmitted: (query) => vm.searchPlayers(query),
                    ),
                  ),
                ),

                // Player list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => vm.refreshPlayers(),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: vm.players.length + (vm.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == vm.players.length) {
                          // Bottom loader
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final player = vm.players[index];

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
                                  builder: (context) => Profile(user: player),
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
            ),
          );
        },
      ),
    );
  }
}

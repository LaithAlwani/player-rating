import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:player_rating/models/app_user.dart';
import 'package:player_rating/provider/auth_provider.dart';
import 'package:player_rating/services/auth_service.dart';

class Profile extends ConsumerWidget {
  const Profile({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (currentUser) {
        final role = currentUser?.role;
        final canEdit = role == "admin";
        return Scaffold(
          appBar: AppBar(
            title: Text("${user.displayName}'s Profile"),
            actions: [
              IconButton(
                onPressed: () async {
                  await AuthService.signOut();
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: Center(
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(user.photoUrl ?? ""),
                  radius: 100,
                ),
                Text(user.displayName, style: const TextStyle(fontSize: 48)),
                Text(user.email, style: const TextStyle(fontSize: 24)),
                Text(
                  (user.rating ?? 0).toString(),
                  style: const TextStyle(fontSize: 32),
                ),
                if (canEdit)
                  ElevatedButton(
                    onPressed: () {
                      // add points to current player
                    },
                    child: const Icon(Icons.add),
                  ),
              ],
            ),
          ),
        );
      },

      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

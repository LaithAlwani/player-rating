import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:player_rating/models/app_user.dart';
import 'package:player_rating/provider/auth_provider.dart';
import 'package:player_rating/services/auth_service.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key, required this.user});

  final AppUser user;

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  late int rating;
  bool isUpdating = false;

  @override
  void initState() {
    rating = widget.user.rating ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (currentUser) {
        final role = currentUser?.role;
        final canEdit = role == "admin";
        return Scaffold(
          appBar: AppBar(
            title: Text("${widget.user.displayName}'s Profile"),
            actions: [
              IconButton(
                onPressed: () async {
                  await AuthService.signOut();
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.user.photoUrl ?? ""),
                  radius: 100,
                ),
                SizedBox(height: 32),
                Text(
                  widget.user.displayName,
                  style: const TextStyle(fontSize: 48),
                  textAlign: TextAlign.center,
                ),
                Text(
                  widget.user.email,
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        (rating != widget.user.rating)
                            ? setState(() {
                                rating -= 1;
                              })
                            : null;
                        // add points to current player
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>((
                              Set<MaterialState> states,
                            ) {
                              if (rating == widget.user.rating) {
                                return Colors.grey;
                              }
                              return null; // Use the component's default.
                            }),
                      ),
                      child: const Icon(Icons.remove),
                    ),
                    Text(
                      (rating).toString(),
                      style: const TextStyle(fontSize: 32),
                    ),
                    if (canEdit)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            rating += 1;
                          });
                          // add points to current player
                        },
                        child: const Icon(Icons.add),
                      ),
                  ],
                ),
                SizedBox(height: 32),
                FilledButton(
                  onPressed: () {
                    print("Saving rating: $rating");

                    // add points to current player
                  },
                  child: const Text("Save"),
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

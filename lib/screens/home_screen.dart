import 'package:flutter/material.dart';
import 'package:player_rating/models/app_user.dart';
import 'package:player_rating/screens/profile.dart';
import 'package:player_rating/services/auth_service.dart';
import 'package:player_rating/services/firestore_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.user});

  final AppUser? user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Stream<List<AppUser>> _playersFuture;

  @override
  void initState() {
    // TODO: implement initState
    _playersFuture = FirestoreService.fethcAllUsers();
    super.initState();
  }

  Future<void> _refreshPlayers() async {
    setState(() {
      _playersFuture = FirestoreService.fethcAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Player Ratings"),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService.signOut();
              // Navigator.pop(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: _playersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No players found."));
          } else {
            final players = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshPlayers,
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  return InkWell(
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Profile(user: player),
                        ),
                      ),
                    },
                    child: ListTile(
                      leading: Hero(
                        tag: player.uid,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            player.photoUrl ?? "dummyProfilePic",
                          ),
                        ),
                      ),
                      title: Text(
                        player.displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      subtitle: Text(
                        player.email,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      trailing: Text(
                        "${player.rating}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}

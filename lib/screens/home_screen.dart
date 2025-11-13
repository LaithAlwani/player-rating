import 'package:flutter/material.dart';
import 'package:player_rating/models/app_user.dart';
import 'package:player_rating/screens/profile.dart';
import 'package:player_rating/services/firestore_services.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.user});

  final AppUser? user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Player Ratings")),
      body: FutureBuilder<List<AppUser>>(
        future: FirestoreService.fethcAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No players found."));
          } else {
            final players = snapshot.data!;
            return Center(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  return InkWell(
                    onTap: () => {
                      Navigator.push(context, MaterialPageRoute(builder: (_)=>Profile(user:player)))
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          player.photoUrl ?? "dummyProfilePic",
                        ),
                      ),
                      title: Text(player.displayName),
                      subtitle: Text(player.email),
                      trailing: Text("${player.rating}"),
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

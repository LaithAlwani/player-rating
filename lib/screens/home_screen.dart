import 'package:flutter/material.dart';
import 'package:player_rating/models/app_user.dart';
import 'package:player_rating/screens/profile.dart';
import 'package:player_rating/utils/dummy_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.user});

 final AppUser? user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Player Ratings")),
      body: Center(
        child: ListView.builder(
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            return InkWell(
              onTap: () => {
                Navigator.push(context, MaterialPageRoute(builder: (_)=>Profile(player:player)))
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(player["image"]),
                ),
                title: Text(player["name"]),
                subtitle: Text("${player["email"]}"),
                trailing: Text("${player["rating"]}"),
              ),
            );
          },
        ),
      ),
    );
  }
}

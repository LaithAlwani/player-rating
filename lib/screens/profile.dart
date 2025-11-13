import 'package:flutter/material.dart';
import 'package:player_rating/models/app_user.dart';

class Profile extends StatelessWidget {
  const Profile({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${user.displayName}'s Profile")),
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
          ],
        ),
      ),
    );
  }
}

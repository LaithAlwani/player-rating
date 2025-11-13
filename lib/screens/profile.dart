import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key, this.player});

  final Map<String, dynamic>? player;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Player Profile")),
      body: Center(
        child: Column(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(player?["image"])),
            Text(player?["name"], style: const TextStyle(fontSize: 20)),
            Text(player?["email"], style: const TextStyle(fontSize: 14)),
            Text(
              (player?["rating"] ?? 0).toString(),
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}

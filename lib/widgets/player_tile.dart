import 'package:flutter/material.dart';
import 'package:lanus_academy/models/app_user.dart';

class PlayerTile extends StatelessWidget {
  const PlayerTile({super.key, required this.player, required this.onTap});

  final AppUser player;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Hero(
        tag: player.uid,
        child: CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(
            player.photoUrl ?? "https://www.gravatar.com/avatar/placeholder",
          ),
        ),
      ),
      title: Text(
        player.displayName,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        player.email,
        style: TextStyle(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          fontFamily: 'Roboto',
        ),
      ),
      trailing: Column(
        children: [
          Text(player.points.toString(), style: const TextStyle(fontSize: 18)),
          Text(
            "${player.overallRating} ${player.position}",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

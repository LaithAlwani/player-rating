import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lanus_academy/main.dart';
import 'package:lanus_academy/models/app_user.dart';
import 'package:lanus_academy/provider/auth_provider.dart';
import 'package:lanus_academy/provider/home_view_model_provider.dart';
import 'package:lanus_academy/widgets/player_stats_grid.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key, required this.user});

  final AppUser user;

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  @override
  void initState() {
    super.initState();
    // Fetch player if not already loaded
    ref.read(homeViewModelProvider.notifier).fetchPlayerById(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);

    final user = state.players.firstWhere(
      (p) => p.uid == widget.user.uid,
      orElse: () => widget.user,
    );

    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? null // default back button
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/logo.png'),
              ),
        title: Text("الملف الشخصي"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => MyApp()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: DefaultTextStyle(
          style: TextStyle(color: Colors.white),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, -50),
                child: Image.asset("assets/player_card.png"),
              ),
              SizedBox(height: 32),
              Positioned(
                top: 50,
                right: 80,
                child: Hero(
                  tag: user.uid,
                  child: ClipOval(
                    child: Image.network(
                      user.photoUrl ??
                          "https://www.gravatar.com/avatar/placeholder",
                      width: 60 * 2, // CircleAvatar radius * 2
                      height: 60 * 2,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 230,
                child: Text(
                  user.displayName,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    // color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                top: 285,
                child: Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    // color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                top: 30,
                left: 80,
                child: Text(
                  user.overallRating.toString(),
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: 95,
                left: 95,
                child: Text(
                  user.position,
                  style: const TextStyle(
                    fontSize: 18,
                    // color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                top: 150,
                left: 75,
                child: Text(
                  DateFormat('dd/MM/yy').format(user.lastLogin.toDate()),

                  style: const TextStyle(
                    fontSize: 16,
                    // color: Colors.white,
                    // fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(bottom: 138, child: PlayerStatsGrid(user: user)),
            ],
          ),
        ),
      ),
    );
  }
}

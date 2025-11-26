import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:lanus_academy/main.dart';
import 'package:lanus_academy/models/app_user.dart';
import 'package:lanus_academy/provider/auth_provider.dart';
import 'package:lanus_academy/provider/home_view_model_provider.dart';
import 'package:lanus_academy/viewmodels/home_viewmodel.dart';
import 'package:lanus_academy/widgets/player_stats_grid.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key, required this.user});

  final AppUser user;

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  AppUser? profileUser;
  // StreamSubscription? _profileSub;
  bool isSaving = false;
  late HomeViewModel homeVM;

  @override
  void initState() {
    print(widget.user.displayName);
    profileUser = widget.user;
    // final authUser = ref.read(authNotifierProvider);
    homeVM = HomeViewModel();
    homeVM.listenToProfileUser(widget.user.uid, (newUser) {
      if (mounted) {
        setState(() => profileUser = newUser);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              homeVM.dispose();
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
                  tag: widget.user.uid,
                  child: ClipOval(
                    child: Image.network(
                      widget.user.photoUrl ??
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
                  widget.user.displayName,
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
                  widget.user.email,
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
                  profileUser?.overallRating.toString() ??
                      widget.user.overallRating.toString(),
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: 95,
                left: 95,
                child: Text(
                  widget.user.position,
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
                  DateFormat('dd/MM/yy').format(widget.user.lastLogin.toDate()),

                  style: const TextStyle(
                    fontSize: 16,
                    // color: Colors.white,
                    // fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                bottom: 138,
                child: PlayerStatsGrid(user: profileUser!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

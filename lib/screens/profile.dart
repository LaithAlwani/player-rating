import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanus_academy/main.dart';
import 'package:lanus_academy/models/app_user.dart';
import 'package:lanus_academy/provider/auth_provider.dart';
import 'package:lanus_academy/services/auth_service.dart';
import 'package:lanus_academy/services/firestore_services.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key, required this.user});

  final AppUser user;

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  late int rating;
  bool isSaving = false;
  late int orginalRating;

  @override
  void initState() {
    rating = widget.user.rating ?? 0;
    orginalRating = widget.user.rating ?? 0;
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
            leading: Navigator.canPop(context)
                ? null // default back button
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/logo.png'),
                  ),
            title: Text("ملف الشخصي"),
            actions: [
              IconButton(
                onPressed: () async {
                  await AuthService.signOut();
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
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, -50),
                  child: Image.asset("assets/player_card_gold.png"),
                ),
                SizedBox(height: 32),
                Positioned(
                  top: 30,
                  right: 60,
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
                  top: 280,
                  child: Text(
                    widget.user.email,
                    style: const TextStyle(
                      fontSize: 18,
                      // color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 85,
                  child: Text(
                    "مهاجم",
                    style: const TextStyle(
                      fontSize: 18,
                      // color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 60,
                  child: Text(
                    "آخر تاريخ دخول",
                    style: const TextStyle(
                      fontSize: 16,
                      // color: Colors.white,
                      // fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                Positioned(
                  bottom: 150,
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (canEdit)
                        ElevatedButton(
                          onPressed: () {
                            (rating != orginalRating)
                                ? setState(() {
                                    rating -= 1;
                                  })
                                : null;
                            // add points to current player
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color?>((
                                  Set<WidgetState> states,
                                ) {
                                  if (rating == orginalRating) {
                                    return Colors.grey;
                                  }
                                  return null; // Use the component's default.
                                }),
                          ),
                          child: const Icon(Icons.remove),
                        ),
                      Text(
                        (rating).toString(),
                        style: const TextStyle(
                          fontSize: 32,
                          // color: Colors.white,
                        ),
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
                ),
                if (canEdit && rating != orginalRating)
                  Positioned(
                    bottom: 0,
                    child: FilledButton(
                      onPressed: (orginalRating != rating && !isSaving)
                          ? () async {
                              setState(() => isSaving = true);

                              await FirestoreService.updateUser(
                                widget.user.uid,
                                {"rating": rating},
                              );

                              setState(() {
                                orginalRating = rating;
                                isSaving = false;
                              });
                              if (mounted) {
                                Navigator.of(context).pop();
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("✅ تم حفظ التقييم بنجاح"),
                                ),
                              );
                            }
                          : null,
                      child: isSaving
                          ? const CircularProgressIndicator()
                          : const Text("حفظ"),
                    ),
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

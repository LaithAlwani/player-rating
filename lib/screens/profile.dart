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
            title: Text("ملف الشخصي ل${widget.user.displayName}"),
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
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: widget.user.uid,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    child: ClipOval(
                      child: Image.network(
                        widget.user.photoUrl ?? "", // your string URL
                        fit: BoxFit.cover, // keeps full image visible
                        errorBuilder: (context, error, stack) =>
                            const Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32),
                Text(
                  widget.user.displayName,
                  style: const TextStyle(fontSize: 36),
                  textAlign: TextAlign.center,
                ),
                Text(
                  widget.user.email,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                Row(
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
                if (canEdit && rating != orginalRating)
                  FilledButton(
                    onPressed: (orginalRating != rating && !isSaving)
                        ? () async {
                            setState(() => isSaving = true);

                            await FirestoreService.updateUser(widget.user.uid, {
                              "rating": rating,
                            });

                            setState(() {
                              orginalRating = rating;
                              isSaving = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("تم الحفظ التقيم بنجاح"),
                              ),
                            );
                          }
                        : null,
                    child: isSaving
                        ? const CircularProgressIndicator()
                        : const Text("حفظ"),
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

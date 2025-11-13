import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:player_rating/firebase_options.dart';
import 'package:player_rating/models/app_user.dart';
import 'package:player_rating/provider/auth_provider.dart';
import 'package:player_rating/screens/home_screen.dart';
import 'package:player_rating/screens/profile.dart';
import 'package:player_rating/screens/wlecome/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Player Rating',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Consumer(
        builder: (context, ref, child) {
          final AsyncValue<AppUser?> user = ref.watch(authProvider);

          return user.when(
            data: (value) {
              print("User: $value");
              if (value == null) return const WelcomeScreen();
              if(value.role != "admin"){
                return Profile(user: value);
              }
              return HomeScreen(user: value);
            },
            error: (error, stack) =>
                Center(child: Text("Error loading auth status: $error")),
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

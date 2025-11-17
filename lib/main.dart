import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanus_academy/firebase_options.dart';
import 'package:lanus_academy/models/app_user.dart';
import 'package:lanus_academy/provider/auth_provider.dart';
import 'package:lanus_academy/screens/home_screen.dart';
import 'package:lanus_academy/screens/profile.dart';
import 'package:lanus_academy/screens/wlecome/welcome.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Launs Academy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF37569a)),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''), // Arabic
        // Add other supported locales here
      ],
      locale: const Locale('ar', ''), // Force Arabic locale
      home: Consumer(
        builder: (context, ref, child) {
          final AsyncValue<AppUser?> user = ref.watch(authProvider);

          return user.when(
            data: (value) {
              if (value == null) return const WelcomeScreen();
              if (value.role != "admin") {
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

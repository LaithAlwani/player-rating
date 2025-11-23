import 'package:arabic_font/arabic_font.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanus_academy/firebase_options.dart';
import 'package:lanus_academy/models/app_user.dart';
import 'package:lanus_academy/provider/auth_provider.dart';
import 'package:lanus_academy/screens/home_screen.dart';
import 'package:lanus_academy/screens/onboadring/onboarding_screen.dart';
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    return MaterialApp(
      title: 'Launs Academy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF37569a)),
        fontFamily: ArabicThemeData.font(arabicFont: ArabicFont.dubai),
        package: ArabicThemeData.package,
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
      home: authState.when(
        data: (user) {
          final firebaseUser = FirebaseAuth.instance.currentUser;
          if (firebaseUser == null) return WelcomeScreen();
          if (user == null) return OnboardingScreen();
          if (user.role != "admin") return Profile(user: user);
          return HomeScreen();
        },
        loading: () =>
            Scaffold(body: const Center(child: CircularProgressIndicator())),
        error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
      ),
      // Consumer(
      //   builder: (context, ref, child) {
      //     final AsyncValue<AppUser?> user = ref.watch(authProvider);
      //     return user.when(
      //       data: (value) {
      //         if (value == null) return const WelcomeScreen();
      //         if (value.role != "admin") {
      //           return Profile(user: value);
      //         }
      //         return HomeScreen();
      //       },
      //       error: (error, stack) =>
      //           Center(child: Text("Error loading auth status: $error")),
      //       loading: () => const Scaffold(
      //         body: Center(child: CircularProgressIndicator()),
      //       ),
      //     );
      //   },
      // ),
    );
  }
}

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:player_rating/models/app_user.dart';
import 'package:player_rating/provider/auth_provider.dart';
import 'package:player_rating/screens/home_screen.dart';
import 'package:player_rating/screens/onboadring/onboadring_name.dart';
import 'package:player_rating/screens/onboadring/onboarding_bottom_navbar.dart';
import 'package:player_rating/screens/onboadring/onboarding_image.dart';
import 'package:player_rating/screens/profile.dart';
import 'package:player_rating/services/firestore_services.dart';
import 'package:player_rating/services/storage_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  User? _currentUser;
  final int _totalPages = 2;
  final PageController _controller = PageController();
  int _currentPage = 0;
  final TextEditingController _nameController = TextEditingController();
  File? _selectedImageFile;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _submitOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitOnboarding() async {
    String? imageUrl;
    // Save user data (to Firestore, local storage, etc.)
    debugPrint("Name: ${_nameController.text}");
    debugPrint("Image: $_selectedImageFile");
    if (_selectedImageFile != null) {
      imageUrl = await StorageService.uploadImageAndGetUrl(
        _selectedImageFile!,
        _currentUser!.uid,
      );
    }
    AppUser user = AppUser(
      uid: _currentUser!.uid,
      email: _currentUser!.email!,
      displayName: _nameController.text,
      photoUrl: imageUrl,
    );

    try {
      await FirestoreService.createUser(user);
      final createdUser = await FirestoreService.getUserById(user.uid);
    
      // ✅ Success — navigate to main layout
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Profile(user: createdUser ?? user) ),
      );
    } catch (e) {
      // ❌ Error — show a message
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to create user: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AppUser?> user = ref.watch(authProvider);
    final firebaseUser = FirebaseAuth.instance.currentUser;
    return user.when(
      data: (value) {
        if (value != null) {
          //if the provider fetchs a user data from the users collection
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(user: value)),
          );
        }
        _currentUser = firebaseUser;
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _controller,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    children: [
                      OnboadringName(nameController: _nameController),
                      OnboardingImage(
                        selectedImage: (file) {
                          _selectedImageFile = file;
                        },
                      ),
                    ],
                  ),
                ),
                OnboardingBottomNavbar(
                  totalPages: _totalPages,
                  currentPage: _currentPage,
                  perviousPage: _previousPage,
                  onNextPage: _nextPage,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:player_rating/shared/image_picker_widget.dart';

class OnboardingImage extends StatelessWidget {
  const OnboardingImage({super.key, required this.selectedImage});
  final Function(File?) selectedImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "add a profile photo?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 12),
          ImagePickerWidget(
            onImageSelected: (file) {
              selectedImage(file);
            },
          ),
        ],
      ),
    );
}}
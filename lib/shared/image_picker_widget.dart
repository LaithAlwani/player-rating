import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({super.key, required this.onImageSelected});

  final Function(File?) onImageSelected;

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImageFile;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile == null) return;

    // Read the original image bytes
    final originalBytes = await pickedFile.readAsBytes();

    // Decode the image for processing
    img.Image? decodedImage = img.decodeImage(originalBytes);
    if (decodedImage == null) return;

    // Resize the image to about 300px width (great for avatars)
    img.Image resized = img.copyResize(decodedImage, width: 300);

    // Compress resized image to ~80% quality
    final resizedBytes = Uint8List.fromList(
      img.encodeJpg(resized, quality: 80),
    );

    // Create a temporary file
    final tempDir = Directory.systemTemp;
    final resizedFile = File(
      '${tempDir.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    // Write the compressed bytes into the file
    await resizedFile.writeAsBytes(resizedBytes);

    // Return the final small image file
    widget.onImageSelected(resizedFile);

    setState(() {
      _selectedImageFile = resizedFile;
    });
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _showImagePickerOptions,
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: _selectedImageFile != null
                ? FileImage(_selectedImageFile!)
                : null,
            child: _selectedImageFile == null
                ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                : null,
          ),
          // CircleAvatar(
          //   radius: 50,
          //   backgroundImage: _selectedImage,
          //   child: _selectedImage == null
          //       ? const Icon(Icons.add_a_photo, size: 40)
          //       : null,
          // ),
          const SizedBox(height: 20),
          const Text("اختر صورة"),
        ],
      ),
    );
  }
}

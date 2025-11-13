import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final ref = FirebaseStorage.instance.ref().child("user_profiles");

  static Future<String> uploadImageAndGetUrl(File file, String uid) async {
    final storageRef = ref.child(
      "${DateTime.now().millisecondsSinceEpoch}-$uid.jpg",
    );
    await storageRef.putFile(file);
    return await storageRef.getDownloadURL();
  }
}

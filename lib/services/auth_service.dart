import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lanus_academy/firebase_options.dart';

class AuthService {
  // google login
  static Future<User?> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: DefaultFirebaseOptions.serverClientId,
      );
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final googleCredential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final UserCredential credential = await FirebaseAuth.instance
          .signInWithCredential(googleCredential);
      final firebaseUser = credential.user;
      if (firebaseUser == null) return null;

      // 🔥 Update lastLogin here
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .set({
            'lastLogin': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (credential.user != null) {
        print("✅ Google Sign-In successful: ${credential.user}");
        return credential.user;
      }
      return null;
    } catch (err) {
      print("❌ Google Sign-In error: $err");
      return null;
    }
  }

  //signup with email and password
}

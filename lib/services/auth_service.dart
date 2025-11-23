import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lanus_academy/firebase_options.dart';
import 'package:lanus_academy/models/app_user.dart';

class AuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // google login
  static Future<User?> signInWithGoogle() async {
    try {
      print(DefaultFirebaseOptions.serverClientId);
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

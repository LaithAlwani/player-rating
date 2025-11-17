import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lanus_academy/firebase_options.dart';

class AuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // google login
  static Future<bool> signInWithGoogle() async {
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
    
      if (credential.user != null) {
        print("✅ Google Sign-In successful: ${credential.user}");
        return true;
        // AppUser(
        //   uid: credential.user!.uid,
        //   email: credential.user!.email!,
        //   displayName: credential.user!.displayName ?? "",
        //   role: "user",
        //   photoUrl: credential.user!.photoURL ?? "",
        // );
      }
      return false;
    } catch (err) {
      print("❌ Google Sign-In error: $err");
      return false;
    }
  }

  //signup with email and password
  static Future<bool> signUp(String email, String password) async {
    try {
      final UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        return true;
      }
      return false;
    } catch (err) {
      return false;
    }
  }

  //login with email and password
  static Future<bool> signIn(String email, String password) async {
    try {
      final UserCredential credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        return true;
      }
      return false;
    } catch (err) {
      return false;
    }
  }

  static Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

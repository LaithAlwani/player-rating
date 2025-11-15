import 'package:firebase_auth/firebase_auth.dart';
import 'package:player_rating/models/app_user.dart';

class AuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

 // google login
  static Future<AppUser?> signInWithGoogle() async {
     print("Google sign-in not implemented yet.");
    return null;
  }

  static Future<AppUser?> signInWithApple() async {
     print("Apple sign-in not implemented yet.");
    return null;
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

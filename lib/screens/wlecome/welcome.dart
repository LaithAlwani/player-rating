import 'package:flutter/material.dart';
import 'package:lanus_academy/screens/wlecome/signin.dart';
import 'package:lanus_academy/screens/wlecome/signup.dart';
import 'package:lanus_academy/services/auth_service.dart';
import 'package:lanus_academy/shared/social_logins.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isSignUpForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // sign up screen
            //add logo
            Image.asset('assets/logo.png', height: 180),
            SizedBox(height: 24),
            //add academy aa a title in big font
            Text(
              "أكاديمية لانوس",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            if (isSignUpForm) const SignUpFrom() else const SignInForm(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(isSignUpForm ? "هل لديك حساب؟ " : "ليس لديك حساب؟ "),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    setState(() {
                      isSignUpForm = !isSignUpForm;
                    });
                  },
                  child: Text(
                    isSignUpForm ? "دخول" : "إنشاء حساب",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            SizedBox(height: 48),
            SocialLoginSection(
              onGoogle: AuthService.signInWithGoogle,
              onApple: () {},
            ),
          ],
        ),
      ),
    );
  }
}

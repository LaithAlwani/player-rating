import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanus_academy/provider/auth_provider.dart';
import 'package:lanus_academy/screens/wlecome/signin.dart';
import 'package:lanus_academy/screens/wlecome/signup.dart';
import 'package:lanus_academy/shared/social_logins.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool isSignUpForm = false;
  bool isSocialLoginLoading = false;

  Future<void> _handleSocialLogin() async {
    setState(() {
      isSocialLoginLoading = true;
    });
    try {
      final success = await ref
          .read(authNotifierProvider.notifier)
          .signInWithGoogle();
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ تم تسجيل الدخول بنجاح")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("❌ فشل تسجيل الدخول")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ فشل تسجيل الدخول: $e")));
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return isSocialLoginLoading
        ? Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
            body: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 80, bottom: 40),
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
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isSignUpForm)
                      const SignUpFrom()
                    else
                      const SignInForm(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isSignUpForm ? "هل لديك حساب؟ " : "ليس لديك حساب؟ ",
                        ),
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
                            isSignUpForm ? "تسجيل دخول" : "إنشاء حساب",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    SocialLoginSection(
                      onGoogle: _handleSocialLogin,
                      onApple: () {},
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

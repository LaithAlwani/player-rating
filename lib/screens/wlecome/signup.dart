import 'package:flutter/material.dart';
import 'package:player_rating/screens/onboadring/onboarding_screen.dart';
import 'package:player_rating/services/auth_service.dart';

class SignUpFrom extends StatefulWidget {
  const SignUpFrom({super.key});

  @override
  State<SignUpFrom> createState() => _SignUpFromState();
}

class _SignUpFromState extends State<SignUpFrom> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorFeedback;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //intro text
            const Center(child: Text("signup for a new account")),
            const SizedBox(height: 16),

            //email address
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "please enter your email";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            //password
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "please enter a passowrd";
                }
                // if (value.length < 8) {
                //   return "Password must be 8 characters in length";
                // }
                return null;
              },
            ),
            //error feedback
            const SizedBox(height: 16),
            if (_errorFeedback != null)
              Text(_errorFeedback!, style: const TextStyle(color: Colors.red)),
            //submit button
            FilledButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _errorFeedback = null;
                  });
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();

                  final success = await AuthService.signUp(email, password);
                  if (success) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingScreen(),
                      ),
                    );
                  } else {
                    setState(() {
                      _errorFeedback = "Could not sign up";
                    });
                  }
                }
                //errorr feedback
              },
              child: const Text("Signup"),
            ),
          ],
        ),
      ),
    );
  }
}

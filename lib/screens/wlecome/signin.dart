import 'package:flutter/material.dart';
import 'package:player_rating/services/auth_service.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
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
            // intro text
            const Center(child: Text('Sign in to your account.')),
            const SizedBox(height: 16.0),

            // email address
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "please enter a email";
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            // password
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "please enter a passowrd";
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            // error feedback
            if (_errorFeedback != null)
              Text(_errorFeedback!, style: const TextStyle(color: Colors.red)),
            // submit button
            FilledButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _errorFeedback = null;
                  });
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();

                  final success = await AuthService.signIn(email, password);

                  if (success){
                    //show snack bar
                  }
                  else {
                    setState(() {
                      _errorFeedback = "Incorrect login credentials";
                    });
                  } 
                }
              },
              child: const Text('Sign In'),
            ),
            // TextButton(
            //   onPressed: () async {
            //     final user = await AuthService.signInWithGoogle();
            //     if (user == null) {
            //       setState(() {
            //         _errorFeedback = "Incorrect login credentials";
            //       });
            //     }
            //   },
            //   child: const Text("Google Sign In"),
            // ),
          ],
        ),
      ),
    );
  }
}

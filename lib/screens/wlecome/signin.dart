import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanus_academy/provider/auth_provider.dart';
import 'package:lanus_academy/services/auth_service.dart';

class SignInForm extends ConsumerStatefulWidget {
  const SignInForm({super.key});

  @override
  ConsumerState<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<SignInForm> {
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
            const Center(
              child: Text('تسجيل الدخول', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16.0),

            // email address
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'بريدك الإلكتروني'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "الرجاء إدخال بريد إلكتروني";
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            // password
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'كلمة المرور'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "الرجاء إدخال كلمة مرور";
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

                  final success = await ref
                      .read(authNotifierProvider.notifier)
                      .signIn(email, password);
                  if (!mounted) return;
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("✅ تم تسجيل الدخول بنجاح")),
                    );
                  } else {
                    setState(() {
                      _errorFeedback = "❌ بيانات تسجيل الدخول غير صحيحة";
                    });
                  }
                }
              },
              child: const Text('تسجيل الدخول'),
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

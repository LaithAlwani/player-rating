import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialLoginSection extends StatelessWidget {
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  const SocialLoginSection({
    super.key,
    required this.onGoogle,
    required this.onApple,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ---- Divider with text ----
        Row(
          children: [
            Expanded(child: Divider(thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "or sign in with",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Expanded(child: Divider(thickness: 1)),
          ],
        ),

        const SizedBox(height: 20),

        // ---- Social Buttons ----
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Button
            _socialButton(
              icon: FontAwesomeIcons.google,
              onTap: onGoogle,
            ),

            const SizedBox(width: 20),

            // Apple Button
            _socialButton(
              icon: FontAwesomeIcons.apple,
              onTap: onApple,
            ),
          ],
        )
      ],
    );
  }

  // Reusable Social Button
  Widget _socialButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            width: 1,
            color: Colors.grey.shade400,
          ),
        ),
        child: Center(
          child: FaIcon(
            icon,
            size: 26,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

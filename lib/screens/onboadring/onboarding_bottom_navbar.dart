import 'package:flutter/material.dart';

class OnboardingBottomNavbar extends StatelessWidget {
  const OnboardingBottomNavbar({
    super.key,
    required this.totalPages,
    required this.currentPage,
    required this.perviousPage,
    required this.onNextPage,
  });

  final int totalPages;
  final int currentPage;
  final VoidCallback perviousPage;
  final VoidCallback onNextPage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: currentPage > 0 ? perviousPage : null,
            style: TextButton.styleFrom(
              foregroundColor: currentPage > 0
                  ? Color(0xFF37569a)
                  : Colors.grey,
            ),
            child: const Text(
              "رجوع",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          ElevatedButton(
            onPressed: onNextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFf6ca54),
              foregroundColor: Color(0xFF37569a),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: Text(
              currentPage == totalPages - 1 ? "تسجيل" : "التالي",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class OnboardingPosition extends StatelessWidget {
  const OnboardingPosition({super.key, required this.positionController});

  final TextEditingController positionController;
  @override
  Widget build(BuildContext context) {
    final Map<String, String> positions = {
      "Goalkeeper": "حارس مرمى",
      "Defender": "مدافع",
      "Midfielder": "لاعب وسط",
      "Forward": "مهاجم",
    };
    return Padding(
      padding: EdgeInsetsGeometry.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "ماهو مركز في الملعب",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField(
            initialValue: positionController.text.isEmpty
                ? null
                : positionController.text,
            decoration: const InputDecoration(
              labelText: "المركز",
              border: OutlineInputBorder(),
            ),
            items: positions.entries.map((option) {
              return DropdownMenuItem(
                value: option.key,
                child: Text(option.value),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                positionController.text = value;
              }
            },
          ),
        ],
      ),
    );
  }
}

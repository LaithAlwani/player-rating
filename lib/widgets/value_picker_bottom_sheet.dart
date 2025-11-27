import 'package:flutter/material.dart';

Future<void> showValuePickerBottomSheet({
  required BuildContext context,
  required String title,
  required int initialValue,
  required Future<void> Function(int value) onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (context) {
      int tempValue = initialValue;
      bool isSaving = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SizedBox(
              height: 350,
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Number Picker
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 50,
                      perspective: 0.003,
                      controller: FixedExtentScrollController(initialItem: 50),
                      onSelectedItemChanged: (index) =>
                          setState(() => tempValue = index + 1),
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          if (index < 0 || index >= 99) return null;
                          return Center(
                            child: Text(
                              (index + 1).toString(),
                              style: TextStyle(
                                fontSize: (index + 1) == tempValue ? 28 : 22,
                                fontWeight: (index + 1) == tempValue
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: (index + 1) == tempValue
                                    ? Colors.blue
                                    : Colors.black,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Save button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            const Color(0xFF37569a),
                          ),
                        ),
                        onPressed: isSaving
                            ? null
                            : () async {
                                setState(() => isSaving = true);
                                await onSave(tempValue);

                                if (context.mounted) Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("✅ تم الحفظ بنجاح"),
                                  ),
                                );
                              },
                        child: isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("حفظ", style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

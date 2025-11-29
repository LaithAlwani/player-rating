import 'package:flutter/material.dart';

Future<void> showValuePickerBottomSheet({
  required BuildContext context,
  required String title,
  String? subtitle,
  required int initialValue,
  bool isPoints = false,
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
                  Text(
                    subtitle ?? "",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Number Picker
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 50,
                      perspective: 0.003,
                      controller: FixedExtentScrollController(
                        initialItem: isPoints ? 0 : initialValue - 1,
                      ),
                      onSelectedItemChanged: (index) => setState(
                        () => tempValue = isPoints ? index * 10 : index + 1,
                      ),
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          final minIndex = isPoints ? -100 : 0;
                          if (index < minIndex || index >= 99) return null;
                          return Center(
                            child: Text(
                              isPoints
                                  ? (index * 10).toString()
                                  : (index + 1).toString(),
                              style: TextStyle(
                                fontSize:
                                    (isPoints ? index * 10 : index + 1) ==
                                        tempValue
                                    ? 28
                                    : 22,
                                fontWeight:
                                    (isPoints ? index * 10 : index + 1) ==
                                        tempValue
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color:
                                    (isPoints ? index * 10 : index + 1) ==
                                        tempValue
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
                                setState(() => isSaving = false);
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

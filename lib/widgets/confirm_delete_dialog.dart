import 'package:flutter/material.dart';
import 'package:lanus_academy/services/firestore_services.dart';

Future<bool> showConfirmDeleteDialog(
  BuildContext context,
  String playerName,
  String uid,
) async {
  bool isSaving = false;
  return await showDialog<bool>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('تأكيد الحذف'),
                content: Text(
                  'هل أنت متأكد أنك تريد حذف اللاعب "$playerName"؟',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('إلغاء'),
                  ),
                  FilledButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: isSaving
                        ? null
                        : () async {
                            setState(() => isSaving = true);

                            final success = await FirestoreService.deleteUser(
                              uid,
                            );
                            setState(() => isSaving = false);
                            if (context.mounted) {
                              if (success) {
                                Navigator.of(context).pop(true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '✅ تم حذف اللاعب "$playerName" بنجاح.',
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '❌ حدث خطأ أثناء حذف اللاعب "$playerName".',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                    child: isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text('حذف'),
                  ),
                ],
              );
            },
          );
        },
      ) ??
      false;
}

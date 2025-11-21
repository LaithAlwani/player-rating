import 'package:flutter/material.dart';

Future<bool> showConfirmDeleteDialog(
  BuildContext context,
  String playerName,
) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('تأكيد الحذف'),
            content: Text('هل أنت متأكد أنك تريد حذف اللاعب "$playerName"؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('إلغاء'),
              ),
              FilledButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('حذف'),
              ),
            ],
          );
        },
      ) ??
      false;
}

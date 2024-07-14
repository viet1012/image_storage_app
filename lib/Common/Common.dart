import 'package:flutter/material.dart';

import 'CustomElevatedButton.dart';

class Dialogs {
  static Future<bool?> showDeleteConfirmationDialog(
      BuildContext context, String title, String content) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            content,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          actions: [
            CustomElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                text: 'No'),
            CustomElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                text: 'Yes'),
          ],
        );
      },
    );
  }
}

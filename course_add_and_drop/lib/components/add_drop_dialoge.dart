import 'package:flutter/material.dart';

void showAddCourseDialog({
  required BuildContext context,
  required VoidCallback onConfirm,
  required VoidCallback onDismiss,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Are you sure you want to add this course?'),
        actions: [
          TextButton(
            onPressed: onDismiss,
            child: const Text(
              'No',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: onConfirm,
            child: const Text(
              'Yes',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ),
        ],
      );
    },
  );
}
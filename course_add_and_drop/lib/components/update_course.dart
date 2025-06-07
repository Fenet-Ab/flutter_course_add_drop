import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Define Course class to match Compose version
class Course {
  final String title;
  final String code;
  final String description;
  final String creditHours; // Using String to match TextField binding

  const Course({
    required this.title,
    required this.code,
    required this.description,
    required this.creditHours,
  });
}

// Define CourseUpdateRequest class to match Compose version
class CourseUpdateRequest {
  final String title;
  final String code;
  final String description;
  final int creditHours; // Parsed to int

  const CourseUpdateRequest({
    required this.title,
    required this.code,
    required this.description,
    required this.creditHours,
  });
}

void showUpdateCourseDialog({
  required BuildContext context,
  required Course course,
  required VoidCallback onDismiss,
  required ValueChanged<CourseUpdateRequest> onSubmit,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return _UpdateCourseDialog(
        course: course,
        onDismiss: onDismiss,
        onSubmit: onSubmit,
      );
    },
  );
}

class _UpdateCourseDialog extends StatefulWidget {
  final Course course;
  final VoidCallback onDismiss;
  final ValueChanged<CourseUpdateRequest> onSubmit;

  const _UpdateCourseDialog({
    Key? key,
    required this.course,
    required this.onDismiss,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _UpdateCourseDialogState createState() => _UpdateCourseDialogState();
}

class _UpdateCourseDialogState extends State<_UpdateCourseDialog> {
  late TextEditingController _titleController;
  late TextEditingController _codeController;
  late TextEditingController _descriptionController;
  late TextEditingController _creditHoursController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course.title);
    _codeController = TextEditingController(text: widget.course.code);
    _descriptionController = TextEditingController(text: widget.course.description);
    _creditHoursController = TextEditingController(text: widget.course.creditHours);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _creditHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Course'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Course Title',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Course Code',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _creditHoursController,
              decoration: const InputDecoration(
                labelText: 'Credit Hours',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onDismiss,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSubmit(
              CourseUpdateRequest(
                title: _titleController.text,
                code: _codeController.text,
                description: _descriptionController.text,
                creditHours: int.tryParse(_creditHoursController.text) ?? 0,
              ),
            );
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
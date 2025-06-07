import 'package:flutter/material.dart';
import '../../components/add_drop_component.dart' as add_drop_components;
import '../../components/button_component.dart' as button; // Assuming you might use your main button component elsewhere, though the card button is custom styled
import '../theme/app_colors.dart';
import 'text.dart' as text;

class CourseCardComponent extends StatelessWidget {
  final String title;
  final String description;
  final String creditHours;
  final VoidCallback onAdd;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String actionButtonText;

  const CourseCardComponent({
    super.key,
    required this.title,
    required this.description,
    required this.creditHours,
    required this.onAdd,
    this.onEdit,
    this.onDelete,
    this.actionButtonText = 'Add now',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: text.HeadingTextComponent(
                    text: title,
                    color: AppColors.colorPrimary,
                  ),
                ),
                Row(
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.colorPrimary),
                        onPressed: onEdit,
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: onDelete,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            text.NormalTextComponent(
              text: description,
              color: AppColors.colorPrimary,
            ),
            const SizedBox(height: 8),
            text.NormalTextComponent(
              text: 'Credit Hours: $creditHours',
              color: AppColors.colorPrimary,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onAdd,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.colorPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(actionButtonText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 
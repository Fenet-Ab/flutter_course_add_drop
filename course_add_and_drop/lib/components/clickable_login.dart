import 'package:flutter/material.dart';

class ClickableLoginTextComponent extends StatelessWidget {
  final VoidCallback onTextSelected;

  const ClickableLoginTextComponent({super.key, required this.onTextSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTextSelected,
      child: const Text(
        'Sign Up',
        style: TextStyle(
          color: Color(0xFF3B82F6),
         
        ),
      ),
    );
  }
}
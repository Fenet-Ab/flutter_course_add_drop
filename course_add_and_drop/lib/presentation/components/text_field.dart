import 'package:flutter/material.dart';

class TextFieldComponent extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String assetPath;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const TextFieldComponent({
    super.key,
    required this.controller,
    required this.label,
    required this.assetPath,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Image.asset(assetPath, width: 24, height: 24),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
} 
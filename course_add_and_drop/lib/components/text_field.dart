import 'package:flutter/material.dart';

class TextFieldComponent extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String assetPath; // Changed from IconData to String for asset path
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final Widget? suffixIcon;

  const TextFieldComponent({
    super.key,
    required this.controller,
    required this.label,
    required this.assetPath,
    this.validator,
    this.keyboardType,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(assetPath, width: 24, height: 24),
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF3B82F6)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        validator: validator,
      ),
    );
  }
}
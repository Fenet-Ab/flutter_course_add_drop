import 'package:flutter/material.dart';

class ButtonComponent extends StatelessWidget {
  final String value;
  final VoidCallback onClick;
  final bool isEnabled;

  const ButtonComponent({
    super.key,
    required this.value,
    required this.onClick,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? onClick : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(value),
    );
  }
} 
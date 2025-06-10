import 'package:flutter/material.dart';

class ButtonComponent extends StatelessWidget {
  final String value;
  final VoidCallback onClick;
  final bool isEnabled;
  final Color? backgroundColor;

  const ButtonComponent({
    super.key,
    required this.value,
    required this.onClick,
    this.isEnabled = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? onClick : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? const Color(0xFF3B82F6),
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
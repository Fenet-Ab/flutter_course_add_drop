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
    return SizedBox(
      width: 260,
      height: 50,
      child: ElevatedButton(
        onPressed: isEnabled ? onClick : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          value,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
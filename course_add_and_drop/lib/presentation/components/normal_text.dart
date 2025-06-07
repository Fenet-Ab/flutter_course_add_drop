import 'package:flutter/material.dart';

class NormalTextComponent extends StatelessWidget {
  final String value;

  const NormalTextComponent({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }
} 
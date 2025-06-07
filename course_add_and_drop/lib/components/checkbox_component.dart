import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CheckboxComponent extends StatelessWidget {
  final String value;
  final ValueChanged<bool> onCheckedChange;
  final VoidCallback onTextSelected;

  const CheckboxComponent({
    super.key,
    required this.value,
    required this.onCheckedChange,
    required this.onTextSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Checkbox(
            value: false,
            onChanged: (value) => onCheckedChange(value!),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: ' Agree with ',
                style: const TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: 'terms',
                    style: const TextStyle(color: Color(0xFF3B82F6)),
                    recognizer: TapGestureRecognizer()..onTap = onTextSelected,
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'conditions',
                    style: const TextStyle(color: Color(0xFF3B82F6)),
                    recognizer: TapGestureRecognizer()..onTap = onTextSelected,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
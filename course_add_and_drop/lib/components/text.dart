import 'package:flutter/material.dart';

class HeadingTextComponent extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;

  const HeadingTextComponent({
    super.key,
    required this.text,
    this.color = Colors.black,
    this.fontSize = 18,
    this.fontWeight = FontWeight.bold,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
    );
  }
}

class NormalTextComponent extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;

  const NormalTextComponent({
    super.key,
    required this.text,
    this.color = Colors.black,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
    );
  }
} 
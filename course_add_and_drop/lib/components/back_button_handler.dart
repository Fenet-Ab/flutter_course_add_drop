import 'package:flutter/material.dart';

class SystemBackButtonHandler extends StatelessWidget {
  final bool enabled;
  final VoidCallback onBackPressed;
  final Widget child;

  const SystemBackButtonHandler({
    Key? key,
    this.enabled = true,
    required this.onBackPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !enabled, // If enabled, prevent default pop behavior
      onPopInvoked: (didPop) {
        if (enabled && !didPop) {
          onBackPressed();
        }
      },
      child: child,
    );
  }
}
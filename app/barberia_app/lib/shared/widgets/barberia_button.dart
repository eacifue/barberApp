import 'package:flutter/material.dart';

import 'app_button.dart';

class BarberiaButton extends StatelessWidget {
  const BarberiaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
    );
  }
}

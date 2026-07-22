import 'package:flutter/material.dart';

import 'app_card.dart';

class BarberiaCard extends StatelessWidget {
  const BarberiaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AppCard(padding: padding, child: child);
  }
}

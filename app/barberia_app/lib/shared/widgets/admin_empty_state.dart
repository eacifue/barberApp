import 'package:flutter/material.dart';

/// Shared empty-state message for admin list tabs (barberías, barberos,
/// servicios, clientes), replacing the four near-identical private copies
/// each tab used to define on its own.
class AdminEmptyState extends StatelessWidget {
  const AdminEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Center(child: Text(message, textAlign: TextAlign.center)),
    );
  }
}

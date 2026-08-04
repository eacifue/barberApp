import 'package:flutter/material.dart';

class AppInput extends StatefulWidget {
  const AppInput({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.autocorrect = true,
    this.minLines,
    this.maxLines = 1,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool autocorrect;
  final int? minLines;
  final int? maxLines;
  final TextInputAction? textInputAction;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText && _obscured,
      autocorrect: widget.autocorrect,
      minLines: widget.minLines,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        suffixIcon: widget.obscureText
            ? IconButton(
                tooltip: _obscured ? 'Mostrar contraseña' : 'Ocultar contraseña',
                icon: Icon(
                  _obscured
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ),
    );
  }
}

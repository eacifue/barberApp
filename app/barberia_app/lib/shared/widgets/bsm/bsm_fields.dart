import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';

/// Etiqueta de campo arriba del control (estilo `label-sm`), con «(opcional)».
class BsmFieldLabel extends StatelessWidget {
  const BsmFieldLabel(this.text, {super.key, this.optional = false});

  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          text: text,
          style: AppTextStyles.labelSm.copyWith(color: p.ink),
          children: [
            if (optional)
              TextSpan(
                text: ' (opcional)',
                style: AppTextStyles.weight(AppTextStyles.labelSm, FontWeight.w400).copyWith(color: p.inkMuted),
              ),
          ],
        ),
      ),
    );
  }
}

Widget _errorRow(AppPalette p, String message) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(LucideIcons.circleAlert, size: 16, color: p.danger),
        ),
        const SizedBox(width: AppSpace.s1),
        Expanded(child: Text(message, style: AppTextStyles.caption.copyWith(color: p.danger))),
      ],
    );

/// Campo de texto (design/docs/componentes/Input.md): etiqueta arriba, ayuda o
/// error debajo, texto a 16 px. Marca lo opcional, no lo obligatorio; el error
/// dice cómo corregir («Ingresa un número de 10 dígitos.»).
class BsmTextField extends StatefulWidget {
  const BsmTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.optional = false,
    this.icon,
    this.revealable = false,
    this.controller,
    this.initialValue,
    this.placeholder,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.maxLines = 1,
    this.enabled = true,
    this.trailing,
    this.focusNode,
  });

  final String? label;
  final String? hint;

  /// Error fijo (p. ej. del servidor). Los del `validator` se muestran igual.
  final String? errorText;
  final bool optional;
  final IconData? icon;

  /// Contraseña con botón Mostrar / Ocultar.
  final bool revealable;
  final TextEditingController? controller;
  final String? initialValue;
  final String? placeholder;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;

  /// Valida al salir del campo y al enviar.
  final AutovalidateMode autovalidateMode;
  final int maxLines;
  final bool enabled;
  final Widget? trailing;
  final FocusNode? focusNode;

  @override
  State<BsmTextField> createState() => _BsmTextFieldState();
}

class _BsmTextFieldState extends State<BsmTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final field = TextFormField(
      controller: widget.controller,
      initialValue: widget.controller == null ? widget.initialValue : null,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      obscureText: widget.revealable && _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      maxLines: widget.revealable ? 1 : widget.maxLines,
      minLines: widget.maxLines > 1 ? 3 : null,
      style: AppTextStyles.bodyLg.copyWith(color: widget.enabled ? p.ink : p.inkDisabled),
      decoration: InputDecoration(
        hintText: widget.placeholder,
        helperText: widget.errorText == null ? widget.hint : null,
        helperMaxLines: 3,
        errorMaxLines: 3,
        error: widget.errorText == null ? null : _errorRow(p, widget.errorText!),
        prefixIcon: widget.icon == null ? null : Icon(widget.icon, size: 20, color: p.inkMuted),
        suffixIcon: widget.revealable
            ? IconButton(
                tooltip: _obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
                icon: Icon(_obscure ? LucideIcons.eye : LucideIcons.eyeOff, size: 20, color: p.inkMuted),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : widget.trailing,
      ),
    );
    if (widget.label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [BsmFieldLabel(widget.label!, optional: widget.optional), field],
    );
  }
}

class BsmOption<T> {
  const BsmOption(this.value, this.label);

  final T value;
  final String label;
}

/// Lista desplegable para pocas opciones (≤ 15) con la misma decoración que el campo.
/// En filtros, «Todos los …» va primero.
class BsmSelect<T> extends StatelessWidget {
  const BsmSelect({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.errorText,
    this.placeholder,
    this.optional = false,
    this.validator,
  });

  final List<BsmOption<T>> options;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? placeholder;
  final bool optional;
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final field = DropdownButtonFormField<T>(
      // La clave fuerza a reflejar cambios externos del valor.
      key: ValueKey<T?>(value),
      initialValue: value,
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
      icon: Icon(LucideIcons.chevronDown, size: 20, color: p.inkMuted),
      style: AppTextStyles.bodyLg.copyWith(color: p.ink),
      dropdownColor: p.surfaceRaised,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      hint: placeholder == null ? null : Text(placeholder!, style: AppTextStyles.bodyLg.copyWith(color: p.inkMuted)),
      decoration: InputDecoration(
        helperText: errorText == null ? hint : null,
        error: errorText == null ? null : _errorRow(p, errorText!),
      ),
      items: [
        for (final o in options) DropdownMenuItem<T>(value: o.value, child: Text(o.label, overflow: TextOverflow.ellipsis)),
      ],
    );
    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [BsmFieldLabel(label!, optional: optional), field],
    );
  }
}

/// Interruptor con etiqueta y ayuda; encendido en latón con check. El cambio
/// aplica al instante y se confirma con un toast.
class BsmSwitchTile extends StatelessWidget {
  const BsmSwitchTile({super.key, required this.label, required this.value, required this.onChanged, this.hint});

  final String label;
  final String? hint;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: AppTextStyles.weight(AppTextStyles.bodyLg, FontWeight.w600).copyWith(color: onChanged == null ? p.inkDisabled : p.ink)),
      subtitle: hint == null ? null : Text(hint!, style: AppTextStyles.body.copyWith(color: p.inkMuted)),
      thumbIcon: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Icon(LucideIcons.check, size: 14, color: p.brass) : null,
      ),
    );
  }
}

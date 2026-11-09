import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/errors/error_message.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../data/auth_repository.dart';
import 'auth_validators.dart';

/// Recuperar contraseña (sin diseño propio; patrones de Login): 1) correo,
/// 2) código de 6 dígitos y contraseña nueva. La API no revela si el correo existe.
class RecuperarScreen extends ConsumerStatefulWidget {
  const RecuperarScreen({super.key, this.correoInicial = ''});

  final String correoInicial;

  @override
  ConsumerState<RecuperarScreen> createState() => _RecuperarScreenState();
}

class _RecuperarScreenState extends ConsumerState<RecuperarScreen> {
  static const _espera = 60;

  final _formCorreo = GlobalKey<FormState>();
  final _formCodigo = GlobalKey<FormState>();
  late final _correo = TextEditingController(text: widget.correoInicial);
  final _codigo = TextEditingController();
  final _clave = TextEditingController();
  final _confirmar = TextEditingController();
  bool _enCodigo = false;
  bool _cargando = false;
  String? _rechazo;
  int _restante = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in [_correo, _codigo, _clave, _confirmar]) {
      c.dispose();
    }
    super.dispose();
  }

  void _arrancarEspera() {
    _timer?.cancel();
    setState(() => _restante = _espera);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _restante--);
      if (_restante <= 0) t.cancel();
    });
  }

  Future<void> _pedirCodigo() async {
    if (!_enCodigo && !(_formCorreo.currentState?.validate() ?? false)) return;
    setState(() => _cargando = true);
    try {
      await ref.read(authRepositoryProvider).solicitarCodigo(_correo.text);
      if (!mounted) return;
      setState(() {
        _enCodigo = true;
        _rechazo = null;
      });
      _arrancarEspera();
    } catch (e) {
      if (mounted) showBsmToast(context, mensajeDeError(e, 'No pudimos enviar el código. Inténtalo de nuevo.'), tone: BsmToastTone.danger);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _restablecer() async {
    setState(() => _rechazo = null);
    if (!(_formCodigo.currentState?.validate() ?? false)) return;
    setState(() => _cargando = true);
    final router = GoRouter.of(context);
    try {
      await ref.read(authRepositoryProvider).restablecer(correo: _correo.text, codigo: _codigo.text, nuevaPassword: _clave.text);
      if (!mounted) return;
      showBsmToast(context, 'Listo, tu contraseña cambió. Ya puedes entrar.');
      router.go('/login');
    } catch (e) {
      if (!mounted) return;
      if (excepcionDe(e) is ValidationException) {
        setState(() => _rechazo = mensajeDeError(e, 'El código no es válido o ya venció. Pide uno nuevo.'));
      } else {
        showBsmToast(context, mensajeDeError(e, 'No pudimos cambiar la contraseña. Inténtalo de nuevo.'), tone: BsmToastTone.danger);
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      appBar: AppBar(
        leading: BsmIconButton(
          icon: LucideIcons.arrowLeft,
          label: _enCodigo ? 'Cambiar correo' : 'Volver a iniciar sesión',
          onPressed: _cargando ? null : () => _enCodigo ? setState(() => _enCodigo = false) : context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpace.s5, AppSpace.s4, AppSpace.s5, AppSpace.s6),
              children: _enCodigo ? _pasoCodigo(p) : _pasoCorreo(p),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _pasoCorreo(AppPalette p) => [
        Semantics(header: true, child: Text('Recupera tu contraseña', style: AppTextStyles.display.copyWith(color: p.ink))),
        const SizedBox(height: AppSpace.s2),
        Text('Te enviamos un código de 6 dígitos al correo de tu cuenta.', style: AppTextStyles.bodyLg.copyWith(color: p.inkMuted)),
        const SizedBox(height: AppSpace.s8),
        Form(
          key: _formCorreo,
          child: BsmTextField(
            controller: _correo,
            label: 'Correo electrónico',
            icon: LucideIcons.mail,
            placeholder: 'nombre@correo.co',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            onSubmitted: (_) => _pedirCodigo(),
            validator: AuthValidators.correo,
          ),
        ),
        const SizedBox(height: AppSpace.s6),
        BsmButton(label: _cargando ? 'Enviando…' : 'Enviar código', size: BsmButtonSize.lg, block: true, loading: _cargando, onPressed: _cargando ? null : _pedirCodigo),
      ];

  List<Widget> _pasoCodigo(AppPalette p) => [
        Semantics(header: true, child: Text('Revisa tu correo', style: AppTextStyles.display.copyWith(color: p.ink))),
        const SizedBox(height: AppSpace.s2),
        Text.rich(
          TextSpan(
            style: AppTextStyles.bodyLg.copyWith(color: p.inkMuted),
            children: [
              const TextSpan(text: 'Si '),
              TextSpan(text: _correo.text.trim(), style: TextStyle(color: p.ink, fontWeight: FontWeight.w600)),
              const TextSpan(text: ' tiene cuenta, te llegó un código. Vence en 15 minutos; revisa también la carpeta de spam.'),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.s6),
        if (_rechazo != null) ...[
          BsmBanner(tone: BsmBannerTone.danger, title: 'No pudimos cambiar la contraseña', body: _rechazo),
          const SizedBox(height: AppSpace.s4),
        ],
        AutofillGroup(
          child: Form(
            key: _formCodigo,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BsmTextField(
                  controller: _codigo,
                  label: 'Código',
                  placeholder: '123456',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                  validator: (v) => RegExp(r'^\d{6}$').hasMatch((v ?? '').trim()) ? null : 'Escribe los 6 dígitos del código.',
                ),
                const SizedBox(height: AppSpace.s4),
                BsmTextField(
                  controller: _clave,
                  label: 'Contraseña nueva',
                  hint: 'Mínimo 6 caracteres.',
                  revealable: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: AuthValidators.clave,
                ),
                const SizedBox(height: AppSpace.s4),
                BsmTextField(
                  controller: _confirmar,
                  label: 'Repite la contraseña',
                  revealable: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: (_) => _restablecer(),
                  validator: (v) => v != _clave.text ? 'Las contraseñas no coinciden.' : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.s6),
        BsmButton(label: _cargando ? 'Guardando…' : 'Cambiar contraseña', size: BsmButtonSize.lg, block: true, loading: _cargando, onPressed: _cargando ? null : _restablecer),
        const SizedBox(height: AppSpace.s4),
        Center(
          child: _restante > 0
              ? Text('Puedes pedir otro código en $_restante s', style: AppTextStyles.body.copyWith(color: p.inkMuted))
              : TextButton(onPressed: _cargando ? null : _pedirCodigo, child: const Text('Enviar otro código')),
        ),
      ];
}

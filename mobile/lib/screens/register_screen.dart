import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/format.dart';
import '../core/nav.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import '../widgets/common.dart';
import 'home_screen.dart';
import 'shared/privacy_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  String _role = 'Ciudadano';
  bool _accepted = false;
  bool _loading = false;
  bool _hide = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _openPrivacy() async {
    final accepted = await Navigator.of(context)
        .push<bool>(AppNav.rise<bool>(const PrivacyScreen(askAccept: true)));
    if (accepted != null && mounted) setState(() => _accepted = accepted);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_accepted) {
      showSnack(context, 'Debes aceptar el aviso de privacidad para registrarte', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final session = await _auth.register(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        role: _role,
        phone: _phone.text.trim(),
        acceptedPrivacy: true,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        AppNav.fade(HomeScreen(session: session)),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      showSnack(context, e.message, error: true);
    } catch (_) {
      if (!mounted) return;
      showSnack(context, 'No se pudo crear la cuenta', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlobBackground(
        child: SafeArea(
          child: Column(
            children: [
              const ScreenHeader(title: 'Crear cuenta', subtitle: 'Únete a PawRescue', showHome: false),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: AppCard(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('¿Cómo quieres usar la app?',
                                  style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.text)),
                              const SizedBox(height: 8),
                              OptionChips(
                                options: const ['Ciudadano', 'Albergue'],
                                selected: _role,
                                icons: const {
                                  'Ciudadano': Icons.person_rounded,
                                  'Albergue': Icons.home_work_rounded,
                                },
                                onSelected: (v) => setState(() => _role = v),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _name,
                                textCapitalization: TextCapitalization.words,
                                decoration: fieldDecoration(
                                    _role == 'Albergue' ? 'Nombre del albergue' : 'Nombre completo',
                                    icon: Icons.badge_outlined),
                                validator: (v) => (v == null || v.trim().length < 3)
                                    ? 'Ingresa al menos 3 caracteres'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                decoration: fieldDecoration('Correo electrónico',
                                    icon: Icons.mail_outline_rounded),
                                validator: (v) => (v == null || !isValidEmail(v))
                                    ? 'Ingresa un correo válido'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _phone,
                                keyboardType: TextInputType.phone,
                                decoration: fieldDecoration('Teléfono (10 dígitos)',
                                    icon: Icons.phone_outlined),
                                validator: (v) => (v == null || !isValidPhone(v))
                                    ? 'Ingresa un teléfono válido'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _password,
                                obscureText: _hide,
                                decoration: fieldDecoration(
                                  'Contraseña (mínimo 8)',
                                  icon: Icons.lock_outline_rounded,
                                  suffix: IconButton(
                                    tooltip: _hide ? 'Mostrar contraseña' : 'Ocultar contraseña',
                                    icon: Icon(_hide
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined),
                                    onPressed: () => setState(() => _hide = !_hide),
                                  ),
                                ),
                                validator: (v) => (v == null || v.length < 8)
                                    ? 'Usa al menos 8 caracteres'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _accepted,
                                    activeColor: AppColors.blue,
                                    onChanged: (v) => setState(() => _accepted = v ?? false),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _openPrivacy,
                                      child: const Text.rich(
                                        TextSpan(
                                          text: 'He leído y acepto el ',
                                          children: [
                                            TextSpan(
                                              text: 'aviso de privacidad',
                                              style: TextStyle(
                                                color: AppColors.blue,
                                                fontWeight: FontWeight.w700,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              AppButton(
                                label: 'Registrarme',
                                icon: Icons.check_rounded,
                                loading: _loading,
                                onPressed: _submit,
                              ),
                              const SizedBox(height: 8),
                              AppButton(
                                label: 'Ya tengo cuenta, volver',
                                kind: AppButtonKind.outline,
                                onPressed: _loading ? null : () => Navigator.of(context).maybePop(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

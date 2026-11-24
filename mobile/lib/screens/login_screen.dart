import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/format.dart';
import '../core/nav.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import '../widgets/common.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _hide = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final session = await _auth.login(_email.text.trim(), _password.text);
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
      showSnack(context, 'No se pudo iniciar sesión', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlobBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SlideFadeIn(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PawLogo(size: 84),
                      const SizedBox(height: 8),
                      const Text(
                        'Cada huella cuenta. Ayúdanos a rescatar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 24),
                      AppCard(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bienvenido de nuevo',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text),
                              ),
                              const SizedBox(height: 4),
                              const Text('Inicia sesión para continuar',
                                  style: TextStyle(color: AppColors.muted)),
                              const SizedBox(height: 18),
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
                                controller: _password,
                                obscureText: _hide,
                                decoration: fieldDecoration(
                                  'Contraseña',
                                  icon: Icons.lock_outline_rounded,
                                  suffix: IconButton(
                                    tooltip: _hide ? 'Mostrar contraseña' : 'Ocultar contraseña',
                                    icon: Icon(_hide
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined),
                                    onPressed: () => setState(() => _hide = !_hide),
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Ingresa tu contraseña'
                                    : null,
                                onFieldSubmitted: (_) => _submit(),
                              ),
                              const SizedBox(height: 20),
                              AppButton(
                                label: 'Iniciar sesión',
                                icon: Icons.login_rounded,
                                loading: _loading,
                                onPressed: _submit,
                              ),
                              if (_loading)
                                const Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text(
                                    'Conectando con el servidor, puede tardar unos segundos...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Crear una cuenta',
                        icon: Icons.person_add_alt_1_rounded,
                        kind: AppButtonKind.accent,
                        onPressed: _loading
                            ? null
                            : () => AppNav.pushRise(context, const RegisterScreen()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

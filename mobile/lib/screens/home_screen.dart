import 'package:flutter/material.dart';
import '../core/nav.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import '../widgets/common.dart';
import 'citizen/citizen_shell.dart';
import 'login_screen.dart';
import 'shared/privacy_screen.dart';
import 'shelter/shelter_shell.dart';

/// Pantalla de inicio: según el rol muestra la experiencia de Ciudadano o de Albergue.
class HomeScreen extends StatefulWidget {
  final UserSession? session;
  const HomeScreen({super.key, this.session});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserSession? _session;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    if (_session != null) {
      _loading = false;
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    final s = await AuthService().currentUser();
    if (!mounted) return;
    if (s == null) {
      Navigator.of(context).pushAndRemoveUntil(
        AppNav.fade(const LoginScreen()),
        (route) => false,
      );
      return;
    }
    setState(() {
      _session = s;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = _session;
    if (_loading || s == null) {
      return const Scaffold(
        body: BlobBackground(child: LoadingView(message: 'Preparando PawRescue...')),
      );
    }
    return s.isShelter ? ShelterShell(session: s) : CitizenShell(session: s);
  }
}

/// Barra inferior con el estilo del diseño.
class PawNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final List<NavigationDestination> destinations;

  const PawNavBar({
    super.key,
    required this.index,
    required this.onChanged,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: onChanged,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.yellow,
          height: 68,
          destinations: destinations,
        ),
      ),
    );
  }
}

/// Pestaña de perfil compartida por ambos roles.
class ProfileTab extends StatelessWidget {
  final UserSession session;
  final List<Widget> extraActions;

  const ProfileTab({super.key, required this.session, this.extraActions = const []});

  Future<void> _logout(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: 'Cerrar sesión',
      message: '¿Seguro que quieres salir de tu cuenta?',
      confirmLabel: 'Salir',
    );
    if (!ok || !context.mounted) return;
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      AppNav.fade(const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = session.name.isEmpty ? '?' : session.name.substring(0, 1).toUpperCase();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const TabHeader(title: 'Mi perfil'),
        SlideFadeIn(
          child: AppCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.yellow,
                  child: Text(initial,
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.text)),
                ),
                const SizedBox(height: 10),
                Text(session.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                StatusChip(
                  text: session.role,
                  color: AppColors.blue,
                  icon: session.isShelter ? Icons.home_work_rounded : Icons.person_rounded,
                ),
                const SizedBox(height: 12),
                InfoRow(icon: Icons.mail_outline_rounded, label: 'Correo', value: session.email),
                InfoRow(
                    icon: Icons.phone_outlined, label: 'Teléfono', value: session.phone ?? ''),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...extraActions.map((w) => Padding(padding: const EdgeInsets.only(bottom: 10), child: w)),
        AppButton(
          label: 'Aviso de privacidad',
          icon: Icons.privacy_tip_outlined,
          kind: AppButtonKind.outline,
          onPressed: () => AppNav.push(context, _privacy()),
        ),
        const SizedBox(height: 10),
        AppButton(
          label: 'Cerrar sesión',
          icon: Icons.logout_rounded,
          kind: AppButtonKind.danger,
          onPressed: () => _logout(context),
        ),
      ],
    );
  }

  Widget _privacy() => const PrivacyScreen();
}

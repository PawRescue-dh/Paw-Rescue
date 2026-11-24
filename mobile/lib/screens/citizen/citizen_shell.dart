import 'package:flutter/material.dart';
import '../../core/nav.dart';
import '../../services/auth_service.dart';
import '../../widgets/common.dart';
import '../home_screen.dart';
import 'my_adoptions_screen.dart';
import 'my_reports_tab.dart';
import 'pet_board_tab.dart';
import 'report_screen.dart';

class CitizenShell extends StatefulWidget {
  final UserSession session;
  const CitizenShell({super.key, required this.session});

  @override
  State<CitizenShell> createState() => _CitizenShellState();
}

class _CitizenShellState extends State<CitizenShell> {
  int _index = 0;
  int _refresh = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlobBackground(
        child: SafeArea(
          child: IndexedStack(
            index: _index,
            children: [
              PetBoardTab(session: widget.session, onReport: () => setState(() => _index = 1)),
              ReportScreen(
                onSent: () => setState(() {
                  _refresh++;
                  _index = 2;
                }),
                onCancel: () => setState(() => _index = 0),
              ),
              MyReportsTab(session: widget.session, refreshToken: _refresh),
              ProfileTab(
                session: widget.session,
                extraActions: [
                  AppButton(
                    label: 'Mis adopciones',
                    icon: Icons.favorite_rounded,
                    kind: AppButtonKind.accent,
                    onPressed: () =>
                        AppNav.push(context, MyAdoptionsScreen(session: widget.session)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PawNavBar(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.warning_amber_rounded), selectedIcon: Icon(Icons.warning_rounded), label: 'SOS'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment_rounded), label: 'Mis reportes'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
    );
  }
}

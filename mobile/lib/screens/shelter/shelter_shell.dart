import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/common.dart';
import '../home_screen.dart';
import 'activity_tab.dart';
import 'adoptions_control_tab.dart';
import 'map_tab.dart';
import 'reports_control_tab.dart';

class ShelterShell extends StatefulWidget {
  final UserSession session;
  const ShelterShell({super.key, required this.session});

  @override
  State<ShelterShell> createState() => _ShelterShellState();
}

class _ShelterShellState extends State<ShelterShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlobBackground(
        child: SafeArea(
          child: IndexedStack(
            index: _index,
            children: [
              MapTab(session: widget.session),
              ReportsControlTab(session: widget.session),
              AdoptionsControlTab(session: widget.session),
              const ActivityTab(),
              ProfileTab(session: widget.session),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PawNavBar(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map_rounded), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment_rounded), label: 'Reportes'),
          NavigationDestination(icon: Icon(Icons.favorite_border_rounded), selectedIcon: Icon(Icons.favorite_rounded), label: 'Adopciones'),
          NavigationDestination(icon: Icon(Icons.history_rounded), selectedIcon: Icon(Icons.history_rounded), label: 'Actividad'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
    );
  }
}

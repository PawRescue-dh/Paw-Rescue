import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/nav.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/pets_service.dart';
import '../../widgets/common.dart';
import 'my_adoptions_screen.dart';
import 'pet_detail_screen.dart';

/// Inicio del ciudadano: tablero de mascotas en adopción.
class PetBoardTab extends StatefulWidget {
  final UserSession session;
  final VoidCallback onReport;
  const PetBoardTab({super.key, required this.session, required this.onReport});

  @override
  State<PetBoardTab> createState() => _PetBoardTabState();
}

class _PetBoardTabState extends State<PetBoardTab> {
  final _service = PetsService();
  List<Pet> _pets = [];
  bool _loading = true;
  String? _error;
  String _filter = 'Todos';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pets = await _service.listAvailable();
      if (!mounted) return;
      setState(() => _pets = pets);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Ocurrió un error inesperado');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(Pet pet) async {
    final sent = await AppNav.push<bool>(
        context, PetDetailScreen(pet: pet, session: widget.session));
    if (sent == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final first = widget.session.name.split(' ').first;
    final visible = _filter == 'Todos'
        ? _pets
        : _pets.where((p) => p.species == _filter).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          TabHeader(
            title: '¡Hola, $first!',
            subtitle: 'Encuentra a tu nuevo mejor amigo',
            trailing: RoundIconButton(
              icon: Icons.favorite_rounded,
              tooltip: 'Mis adopciones',
              onTap: () => AppNav.push(context, MyAdoptionsScreen(session: widget.session)),
            ),
          ),
          SlideFadeIn(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.yellow,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.yellowDark.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reportar animal',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text)),
                        SizedBox(height: 4),
                        Text('¿Viste un animalito que necesita ayuda? Avisa al albergue.',
                            style: TextStyle(color: AppColors.text)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: widget.onReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Icon(Icons.camera_alt_rounded),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Mascotas en adopción',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          OptionChips(
            options: const ['Todos', 'Perro', 'Gato', 'Otro'],
            selected: _filter,
            icons: const {'Perro': Icons.pets, 'Gato': Icons.cruelty_free_rounded},
            onSelected: (v) => setState(() => _filter = v),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(padding: EdgeInsets.all(40), child: LoadingView())
          else if (_error != null)
            ErrorView(message: _error!, onRetry: _load)
          else if (visible.isEmpty)
            const EmptyState(
              icon: Icons.pets,
              title: 'Aún no hay mascotas aquí',
              subtitle: 'Cuando el albergue publique nuevas mascotas aparecerán en este tablero.',
            )
          else
            for (int i = 0; i < visible.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: SlideFadeIn(index: i, child: _PetCard(pet: visible[i], onTap: () => _open(visible[i]))),
              ),
        ],
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback onTap;
  const _PetCard({required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            child: SizedBox(width: 120, height: 130, child: PetPhoto(base64: pet.photoBase64, height: 130, width: 120)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(pet.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      ),
                      StatusChip(text: pet.status, color: petStatusColor(pet.status)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('${pet.species} · ${pet.age} · ${pet.sex}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.home_work_rounded, size: 15, color: AppColors.blue),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(pet.shelterName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.phone_rounded, size: 15, color: AppColors.blue),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(pet.shelterPhone.isEmpty ? 'Sin teléfono' : pet.shelterPhone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

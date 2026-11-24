import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/format.dart';
import '../../core/nav.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/pets_service.dart';
import '../../widgets/common.dart';
import 'add_pet_screen.dart';

/// Control de adopciones: solicitudes recibidas y mascotas publicadas.
class AdoptionsControlTab extends StatefulWidget {
  final UserSession session;
  const AdoptionsControlTab({super.key, required this.session});

  @override
  State<AdoptionsControlTab> createState() => _AdoptionsControlTabState();
}

class _AdoptionsControlTabState extends State<AdoptionsControlTab> {
  final _service = PetsService();
  List<AdoptionRequest> _requests = [];
  List<Pet> _pets = [];
  bool _loading = true;
  String? _error;
  String _view = 'Solicitudes';

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
      final results = await Future.wait([_service.allRequests(), _service.listAll()]);
      if (!mounted) return;
      setState(() {
        _requests = results[0] as List<AdoptionRequest>;
        _pets = results[1] as List<Pet>;
      });
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

  Future<void> _decide(AdoptionRequest r, String status) async {
    final ok = await confirmDialog(
      context,
      title: status == 'Aprobada' ? 'Aprobar adopción' : 'Rechazar solicitud',
      message: status == 'Aprobada'
          ? '${r.citizenName} se quedará con ${r.pet?.name ?? 'la mascota'}. Saldrá del tablero.'
          : 'La mascota volverá a estar disponible en el tablero.',
      confirmLabel: status == 'Aprobada' ? 'Aprobar' : 'Rechazar',
      danger: status == 'Rechazada',
    );
    if (!ok || !mounted) return;
    try {
      await _service.decide(r.id, status);
      if (!mounted) return;
      showSnack(context, 'Solicitud ${status == 'Aprobada' ? 'aprobada' : 'rechazada'}');
      _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      showSnack(context, e.message, error: true);
    }
  }

  Future<void> _addPet() async {
    final added = await AppNav.pushRise<bool>(context, AddPetScreen(session: widget.session));
    if (added == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final pending = _requests.where((r) => r.status == 'Pendiente').length;
    return Column(
      children: [
        TabHeader(
          title: 'Control de adopciones',
          subtitle: '$pending solicitudes pendientes',
          trailing: RoundIconButton(icon: Icons.add_rounded, tooltip: 'Publicar mascota', onTap: _addPet),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: OptionChips(
              options: const ['Solicitudes', 'Mascotas'],
              selected: _view,
              onSelected: (v) => setState(() => _view = v),
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const LoadingView()
              : _error != null
                  ? ErrorView(message: _error!, onRetry: _load)
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: _view == 'Solicitudes' ? _requestList() : _petList(),
                    ),
        ),
      ],
    );
  }

  Widget _requestList() {
    if (_requests.isEmpty) {
      return ListView(children: const [
        EmptyState(
          icon: Icons.favorite_border_rounded,
          title: 'Sin solicitudes',
          subtitle: 'Cuando un ciudadano quiera adoptar, su solicitud aparecerá aquí.',
        ),
      ]);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: _requests.length,
      itemBuilder: (context, i) {
        final r = _requests[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SlideFadeIn(
            index: i,
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                            width: 52,
                            height: 52,
                            child: PetPhoto(base64: r.pet?.photoBase64, width: 52, height: 52)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.pet?.name ?? 'Mascota',
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                            Text(timeAgo(r.createdAt),
                                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                          ],
                        ),
                      ),
                      StatusChip(text: r.status, color: requestStatusColor(r.status)),
                    ],
                  ),
                  const Divider(height: 20),
                  InfoRow(icon: Icons.person_rounded, label: 'Ciudadano', value: r.citizenName),
                  InfoRow(icon: Icons.phone_rounded, label: 'Teléfono', value: r.citizenPhone, copyable: true),
                  InfoRow(icon: Icons.mail_outline_rounded, label: 'Correo', value: r.citizenEmail, copyable: true),
                  if (r.message != null && r.message!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('“${r.message}”',
                          style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.muted)),
                    ),
                  if (r.status == 'Pendiente') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Rechazar',
                            kind: AppButtonKind.outline,
                            onPressed: () => _decide(r, 'Rechazada'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppButton(
                            label: 'Aprobar',
                            icon: Icons.check_rounded,
                            onPressed: () => _decide(r, 'Aprobada'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _petList() {
    if (_pets.isEmpty) {
      return ListView(children: [
        EmptyState(
          icon: Icons.pets,
          title: 'Aún no publicas mascotas',
          subtitle: 'Agrega a tus animalitos para que los ciudadanos puedan adoptarlos.',
          action: AppButton(label: 'Publicar mascota', icon: Icons.add_rounded, expand: false, onPressed: _addPet),
        ),
      ]);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: _pets.length,
      itemBuilder: (context, i) {
        final p = _pets[i];
        final hasAdopter = p.adopterName != null && p.adopterName!.isNotEmpty;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SlideFadeIn(
            index: i,
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                            width: 56,
                            height: 56,
                            child: PetPhoto(base64: p.photoBase64, width: 56, height: 56)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                            Text('${p.species} · ${p.age} · ${p.sex}',
                                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                          ],
                        ),
                      ),
                      StatusChip(text: p.status, color: petStatusColor(p.status)),
                    ],
                  ),
                  if (hasAdopter) ...[
                    const Divider(height: 20),
                    Text(
                        p.status == 'Adoptada' ? 'Adoptada por' : 'Reservada por',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, color: AppColors.muted, fontSize: 12)),
                    InfoRow(icon: Icons.person_rounded, label: 'Ciudadano', value: p.adopterName ?? ''),
                    InfoRow(icon: Icons.phone_rounded, label: 'Teléfono', value: p.adopterPhone ?? '', copyable: true),
                    InfoRow(icon: Icons.mail_outline_rounded, label: 'Correo', value: p.adopterEmail ?? '', copyable: true),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

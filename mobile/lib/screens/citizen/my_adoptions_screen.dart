import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/pets_service.dart';
import '../../widgets/common.dart';

/// Solicitudes de adopción del ciudadano, con los datos de adopción de cada mascota.
class MyAdoptionsScreen extends StatefulWidget {
  final UserSession session;
  const MyAdoptionsScreen({super.key, required this.session});

  @override
  State<MyAdoptionsScreen> createState() => _MyAdoptionsScreenState();
}

class _MyAdoptionsScreenState extends State<MyAdoptionsScreen> {
  final _service = PetsService();
  List<AdoptionRequest> _items = [];
  bool _loading = true;
  String? _error;

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
      final items = await _service.myRequests();
      if (!mounted) return;
      setState(() => _items = items);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlobBackground(
        child: SafeArea(
          child: Column(
            children: [
              const ScreenHeader(title: 'Mis adopciones', subtitle: 'Seguimiento de tus solicitudes'),
              Expanded(
                child: _loading
                    ? const LoadingView()
                    : _error != null
                        ? ErrorView(message: _error!, onRetry: _load)
                        : _items.isEmpty
                            ? const EmptyState(
                                icon: Icons.favorite_border_rounded,
                                title: 'Aún no solicitas ninguna adopción',
                                subtitle: 'Elige una mascota del tablero y envía tu solicitud.',
                              )
                            : RefreshIndicator(
                                onRefresh: _load,
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                                  itemCount: _items.length,
                                  itemBuilder: (context, i) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: SlideFadeIn(index: i, child: _tile(_items[i])),
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

  Widget _tile(AdoptionRequest r) {
    final pet = r.pet;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                    width: 64,
                    height: 64,
                    child: PetPhoto(base64: pet?.photoBase64, width: 64, height: 64)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pet?.name ?? 'Mascota',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    Text(formatDateTime(r.createdAt),
                        style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ),
              StatusChip(text: r.status, color: requestStatusColor(r.status)),
            ],
          ),
          const Divider(height: 22),
          const Text('Tus datos de adopción',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.muted)),
          InfoRow(icon: Icons.person_rounded, label: 'Adoptante', value: r.citizenName),
          InfoRow(icon: Icons.phone_rounded, label: 'Tu teléfono', value: r.citizenPhone),
          if (pet != null) ...[
            InfoRow(icon: Icons.home_work_rounded, label: 'Albergue', value: pet.shelterName),
            InfoRow(
                icon: Icons.phone_in_talk_rounded,
                label: 'Teléfono del albergue',
                value: pet.shelterPhone,
                copyable: true),
          ],
          if (r.status == 'Aprobada')
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('¡Felicidades! Tu adopción fue aprobada.',
                  style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

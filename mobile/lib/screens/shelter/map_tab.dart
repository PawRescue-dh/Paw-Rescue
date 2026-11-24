import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/api_client.dart';
import '../../core/format.dart';
import '../../core/nav.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/reports_service.dart';
import '../../widgets/common.dart';
import '../shared/report_detail_screen.dart';

/// Mapa del Albergue: ocupa la mitad superior; la descripción completa va debajo.
class MapTab extends StatefulWidget {
  final UserSession session;
  const MapTab({super.key, required this.session});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  static const LatLng _defaultCenter = LatLng(21.1561, -100.9308);

  final _service = ReportsService();
  final _controller = MapController();
  List<Report> _reports = [];
  Report? _selected;
  Report? _selectedFull;
  bool _loading = true;
  bool _loadingDetail = false;
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
      final reports = await _service.getReports();
      if (!mounted) return;
      setState(() {
        _reports = reports;
        if (_selected != null) {
          final still = reports.where((r) => r.id == _selected!.id).toList();
          _selected = still.isEmpty ? null : still.first;
          if (_selected == null) _selectedFull = null;
        }
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

  Future<void> _select(Report r) async {
    setState(() {
      _selected = r;
      _selectedFull = null;
      _loadingDetail = true;
    });
    _controller.move(LatLng(r.latitude, r.longitude), 16);
    try {
      final full = await _service.getReportById(r.id);
      if (!mounted || _selected?.id != r.id) return;
      setState(() => _selectedFull = full);
    } catch (_) {
      // Se muestra la descripción sin foto.
    } finally {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  void _clear() => setState(() {
        _selected = null;
        _selectedFull = null;
      });

  void _recenter() {
    if (_reports.isEmpty) {
      _controller.move(_defaultCenter, 14);
    } else {
      final r = _reports.first;
      _controller.move(LatLng(r.latitude, r.longitude), 14);
    }
  }

  Future<void> _setStatus(Report r, String status) async {
    try {
      await _service.updateStatus(r.id, status);
      if (!mounted) return;
      showSnack(context, 'Reporte marcado como "$status"');
      await _load();
      if (_selected != null) _select(_selected!);
    } on ApiException catch (e) {
      if (!mounted) return;
      showSnack(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 5, child: _mapArea()),
        Expanded(flex: 5, child: _detailArea()),
      ],
    );
  }

  Widget _mapArea() {
    final markers = _reports.map((r) {
      final isSel = _selected?.id == r.id;
      final color = urgencyColor(r.urgency);
      return Marker(
        point: LatLng(r.latitude, r.longitude),
        width: isSel ? 56 : 42,
        height: isSel ? 56 : 42,
        child: GestureDetector(
          onTap: () => _select(r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: isSel ? 4 : 2),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
            ),
            child: Icon(Icons.pets, color: Colors.white, size: isSel ? 28 : 20),
          ),
        ),
      );
    }).toList();

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
          child: FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 14.0,
              onTap: (tapPosition, point) => _clear(),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.pawrescue.app',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
        ),
        Positioned(
          top: 10,
          left: 12,
          right: 12,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.map_rounded, color: AppColors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _loading ? 'Cargando reportes...' : '${_reports.length} reportes en el mapa',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              RoundIconButton(icon: Icons.my_location_rounded, tooltip: 'Centrar', onTap: _recenter),
              const SizedBox(width: 8),
              RoundIconButton(icon: Icons.refresh_rounded, tooltip: 'Actualizar', onTap: _load),
            ],
          ),
        ),
        if (_loading) const Positioned.fill(child: Center(child: CircularProgressIndicator())),
      ],
    );
  }

  Widget _detailArea() {
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _load);
    }
    final r = _selected;
    if (r == null) {
      return const EmptyState(
        icon: Icons.touch_app_rounded,
        title: 'Selecciona un reporte',
        subtitle: 'Toca un punto del mapa para ver aquí la descripción completa.',
      );
    }
    final full = _selectedFull ?? r;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SlideFadeIn(
        key: ValueKey(r.id),
        dy: 12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('${r.species} · ${timeAgo(r.createdAt)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ),
                IconButton(
                  tooltip: 'Cerrar detalle',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: _clear,
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                StatusChip(text: r.status, color: reportStatusColor(r.status)),
                StatusChip(
                    text: 'Urgencia ${r.urgency}',
                    color: urgencyColor(r.urgency),
                    icon: Icons.warning_amber_rounded),
                StatusChip(
                    text: r.reporterName ?? 'Ciudadano',
                    color: AppColors.blue,
                    icon: Icons.person_rounded),
              ],
            ),
            const SizedBox(height: 10),
            if (_loadingDetail)
              const LinearProgressIndicator(minHeight: 3)
            else if (full.photoBase64 != null && full.photoBase64!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: PetPhoto(base64: full.photoBase64, height: 150)),
                ),
              ),
            Text(full.description, style: const TextStyle(fontSize: 15, height: 1.4)),
            const SizedBox(height: 12),
            OptionChips(
              options: const ['Pendiente', 'En atención', 'Resuelto'],
              selected: r.status,
              colorOf: reportStatusColor,
              onSelected: (v) {
                if (v != r.status) _setStatus(r, v);
              },
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Ver detalle y comentarios',
              icon: Icons.chat_rounded,
              kind: AppButtonKind.outline,
              onPressed: () async {
                await AppNav.push(
                    context, ReportDetailScreen(reportId: r.id, session: widget.session));
                _load();
              },
            ),
          ],
        ),
      ),
    );
  }
}

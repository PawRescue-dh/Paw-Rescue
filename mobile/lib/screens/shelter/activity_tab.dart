import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/activity_service.dart';
import '../../widgets/common.dart';

/// Registro de acciones: nuevos reportes, solicitudes de adopción, comentarios...
class ActivityTab extends StatefulWidget {
  const ActivityTab({super.key});

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  final _service = ActivityService();
  List<ActivityItem> _items = [];
  bool _loading = true;
  String? _error;
  String _filter = 'Todo';

  static const Map<String, String> _filters = {
    'Todo': '',
    'Reportes': 'reporte',
    'Estados': 'estado',
    'Comentarios': 'comentario',
    'Mascotas': 'mascota',
    'Adopciones': 'adopcion',
  };

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
      final items = await _service.list();
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

  IconData _icon(String type) {
    switch (type) {
      case 'reporte':
        return Icons.campaign_rounded;
      case 'estado':
        return Icons.sync_alt_rounded;
      case 'comentario':
        return Icons.chat_bubble_rounded;
      case 'mascota':
        return Icons.pets;
      case 'adopcion':
        return Icons.favorite_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _color(String type) {
    switch (type) {
      case 'reporte':
        return AppColors.danger;
      case 'estado':
        return AppColors.blue;
      case 'comentario':
        return AppColors.orange;
      case 'mascota':
        return AppColors.success;
      case 'adopcion':
        return const Color(0xFFD6417F);
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = _filters[_filter] ?? '';
    final visible = type.isEmpty ? _items : _items.where((a) => a.type == type).toList();
    return Column(
      children: [
        TabHeader(
          title: 'Registro de acciones',
          subtitle: 'Todo lo que ocurre en la app',
          trailing: RoundIconButton(icon: Icons.refresh_rounded, tooltip: 'Actualizar', onTap: _load),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _filters.keys
                .map((k) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: OptionChips(
                        options: [k],
                        selected: _filter,
                        onSelected: (v) => setState(() => _filter = v),
                      ),
                    ))
                .toList(),
          ),
        ),
        Expanded(
          child: _loading
              ? const LoadingView()
              : _error != null
                  ? ErrorView(message: _error!, onRetry: _load)
                  : visible.isEmpty
                      ? const EmptyState(
                          icon: Icons.history_rounded,
                          title: 'Sin actividad',
                          subtitle: 'Aquí aparecerán los reportes, solicitudes y comentarios.',
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: visible.length,
                            itemBuilder: (context, i) {
                              final a = visible[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: AppCard(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: _color(a.type).withValues(alpha: 0.14),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(_icon(a.type), color: _color(a.type), size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(a.message,
                                                style: const TextStyle(fontWeight: FontWeight.w600)),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${a.actorName ?? 'Sistema'}'
                                              '${a.actorRole == null ? '' : ' · ${a.actorRole}'}'
                                              ' · ${timeAgo(a.createdAt)}',
                                              style: const TextStyle(
                                                  color: AppColors.muted, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}

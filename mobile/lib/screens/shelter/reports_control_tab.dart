import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/format.dart';
import '../../core/nav.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/reports_service.dart';
import '../../widgets/common.dart';
import '../shared/report_detail_screen.dart';

/// Control de reportes: contadores por estado, filtros y lista.
class ReportsControlTab extends StatefulWidget {
  final UserSession session;
  const ReportsControlTab({super.key, required this.session});

  @override
  State<ReportsControlTab> createState() => _ReportsControlTabState();
}

class _ReportsControlTabState extends State<ReportsControlTab> {
  final _service = ReportsService();
  List<Report> _items = [];
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
      final items = await _service.getReports();
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

  int _count(String status) => _items.where((r) => r.status == status).length;

  Widget _stat(String label, int n, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text('$n', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filter == 'Todos' ? _items : _items.where((r) => r.status == _filter).toList();
    return Column(
      children: [
        const TabHeader(title: 'Control de reportes', subtitle: 'Atiende y da seguimiento'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _stat('Pendientes', _count('Pendiente'), AppColors.warning),
              _stat('En atención', _count('En atención'), AppColors.blue),
              _stat('Resueltos', _count('Resuelto'), AppColors.success),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: OptionChips(
              options: const ['Todos', 'Pendiente', 'En atención', 'Resuelto'],
              selected: _filter,
              onSelected: (v) => setState(() => _filter = v),
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const LoadingView()
              : _error != null
                  ? ErrorView(message: _error!, onRetry: _load)
                  : visible.isEmpty
                      ? const EmptyState(
                          icon: Icons.inbox_rounded,
                          title: 'Sin reportes',
                          subtitle: 'No hay reportes con este filtro.',
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: visible.length,
                            itemBuilder: (context, i) {
                              final r = visible[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: SlideFadeIn(
                                  index: i,
                                  child: AppCard(
                                    onTap: () async {
                                      await AppNav.push(
                                          context,
                                          ReportDetailScreen(
                                              reportId: r.id, session: widget.session));
                                      _load();
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text('${r.species} · ${r.reporterName ?? 'Ciudadano'}',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.w800, fontSize: 16)),
                                            ),
                                            StatusChip(
                                                text: r.status,
                                                color: reportStatusColor(r.status)),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(r.description,
                                            maxLines: 2, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            StatusChip(
                                                text: r.urgency, color: urgencyColor(r.urgency)),
                                            const SizedBox(width: 8),
                                            Text(timeAgo(r.createdAt),
                                                style: const TextStyle(
                                                    color: AppColors.muted, fontSize: 12)),
                                          ],
                                        ),
                                      ],
                                    ),
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

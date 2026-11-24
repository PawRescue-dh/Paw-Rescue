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

class MyReportsTab extends StatefulWidget {
  final UserSession session;
  final int refreshToken;
  const MyReportsTab({super.key, required this.session, this.refreshToken = 0});

  @override
  State<MyReportsTab> createState() => _MyReportsTabState();
}

class _MyReportsTabState extends State<MyReportsTab> {
  final _service = ReportsService();
  List<Report> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant MyReportsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) _load();
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TabHeader(title: 'Mis reportes', subtitle: 'Seguimiento de tus alertas'),
        Expanded(
          child: _loading
              ? const LoadingView()
              : _error != null
                  ? ErrorView(message: _error!, onRetry: _load)
                  : _items.isEmpty
                      ? const EmptyState(
                          icon: Icons.assignment_outlined,
                          title: 'Aún no has enviado reportes',
                          subtitle: 'Cuando reportes un animal podrás ver aquí cómo avanza su atención.',
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            itemCount: _items.length,
                            itemBuilder: (context, i) {
                              final r = _items[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
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
                                              child: Text('${r.species} · ${timeAgo(r.createdAt)}',
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
                                        StatusChip(
                                            text: 'Urgencia ${r.urgency}',
                                            color: urgencyColor(r.urgency)),
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

import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/reports_service.dart';
import '../../widgets/common.dart';

/// Detalle de un reporte con foto, estado y comentarios. El Albergue puede cambiar el estado.
class ReportDetailScreen extends StatefulWidget {
  final String reportId;
  final UserSession session;
  const ReportDetailScreen({super.key, required this.reportId, required this.session});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final _service = ReportsService();
  final _comment = TextEditingController();
  Report? _report;
  List<ReportComment> _comments = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final report = await _service.getReportById(widget.reportId);
      final comments = await _service.getComments(widget.reportId);
      if (!mounted) return;
      setState(() {
        _report = report;
        _comments = comments;
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

  Future<void> _setStatus(String status) async {
    try {
      await _service.updateStatus(widget.reportId, status);
      _changed = true;
      if (!mounted) return;
      showSnack(context, 'Estado actualizado a "$status"');
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      showSnack(context, e.message, error: true);
    }
  }

  Future<void> _send() async {
    final text = _comment.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await _service.addComment(widget.reportId, text);
      _comment.clear();
      _changed = true;
      final comments = await _service.getComments(widget.reportId);
      if (!mounted) return;
      setState(() => _comments = comments);
    } on ApiException catch (e) {
      if (!mounted) return;
      showSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _report;
    return Scaffold(
        body: BlobBackground(
          child: SafeArea(
            child: Column(
              children: [
                ScreenHeader(
                  title: 'Detalle del reporte',
                  subtitle: r == null ? null : '${r.species} · ${timeAgo(r.createdAt)}',
                  onBack: () => Navigator.of(context).pop(_changed),
                ),
                Expanded(
                  child: _loading
                      ? const LoadingView()
                      : _error != null || r == null
                          ? ErrorView(message: _error ?? 'Reporte no disponible', onRetry: _load)
                          : _body(r),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget _body(Report r) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        if (r.photoBase64 != null && r.photoBase64!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(height: 220, child: PetPhoto(base64: r.photoBase64, height: 220)),
          ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  StatusChip(text: r.status, color: reportStatusColor(r.status)),
                  StatusChip(
                      text: 'Urgencia ${r.urgency}',
                      color: urgencyColor(r.urgency),
                      icon: Icons.warning_amber_rounded),
                  StatusChip(text: r.species, color: AppColors.blue, icon: Icons.pets),
                ],
              ),
              const SizedBox(height: 12),
              Text(r.description, style: const TextStyle(fontSize: 15, height: 1.4)),
              const Divider(height: 24),
              InfoRow(
                  icon: Icons.person_rounded,
                  label: 'Reportado por',
                  value: r.reporterName ?? 'Ciudadano'),
              InfoRow(
                  icon: Icons.schedule_rounded,
                  label: 'Fecha',
                  value: formatDateTime(r.createdAt)),
              InfoRow(
                  icon: Icons.place_rounded,
                  label: 'Ubicación',
                  value: '${r.latitude.toStringAsFixed(5)}, ${r.longitude.toStringAsFixed(5)}',
                  copyable: true),
            ],
          ),
        ),
        if (widget.session.isShelter) ...[
          const SizedBox(height: 14),
          const Text('Cambiar estado', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          OptionChips(
            options: const ['Pendiente', 'En atención', 'Resuelto'],
            selected: r.status,
            colorOf: reportStatusColor,
            onSelected: (v) {
              if (v != r.status) _setStatus(v);
            },
          ),
        ],
        const SizedBox(height: 18),
        Text('Comentarios (${_comments.length})',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 8),
        if (_comments.isEmpty)
          const Text('Aún no hay comentarios.', style: TextStyle(color: AppColors.muted))
        else
          for (final c in _comments)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                color: c.authorRole == 'Albergue' ? AppColors.blueLight : Colors.white,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('${c.authorName} · ${c.authorRole}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                        Text(timeAgo(c.createdAt),
                            style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(c.text),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 8),
        TextField(
          controller: _comment,
          maxLines: 2,
          maxLength: 500,
          decoration: fieldDecoration('Escribe un comentario', icon: Icons.chat_bubble_outline_rounded),
        ),
        AppButton(
          label: 'Enviar comentario',
          icon: Icons.send_rounded,
          loading: _sending,
          onPressed: _send,
        ),
      ],
    );
  }
}

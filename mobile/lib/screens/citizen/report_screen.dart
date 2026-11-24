import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../services/reports_service.dart';
import '../../widgets/common.dart';
import '../../widgets/photo_picker.dart';

/// SOS: formulario para reportar un animal. Se usa como pestaña principal.
class ReportScreen extends StatefulWidget {
  final VoidCallback? onSent;
  final VoidCallback? onCancel;
  const ReportScreen({super.key, this.onSent, this.onCancel});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  static const double _defaultLat = 21.1561;
  static const double _defaultLng = -100.9308;

  final _service = ReportsService();
  final _description = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _species = 'Perro';
  String _urgency = 'Media';
  Uint8List? _photo;
  double _lat = _defaultLat;
  double _lng = _defaultLng;
  bool _locating = false;
  bool _gpsOk = false;
  bool _sending = false;
  int _photoKey = 0;

  @override
  void initState() {
    super.initState();
    _locate();
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    setState(() => _locating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) throw Exception('GPS apagado');
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Sin permiso');
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      if (!mounted) return;
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _gpsOk = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _lat = _defaultLat;
        _lng = _defaultLng;
        _gpsOk = false;
      });
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      await _service.createReport(
        species: _species,
        urgency: _urgency,
        description: _description.text.trim(),
        latitude: _lat,
        longitude: _lng,
        photoBase64: _photo == null ? null : base64Encode(_photo!),
      );
      if (!mounted) return;
      showSnack(context, '¡Alerta enviada! El albergue fue notificado.');
      _description.clear();
      setState(() {
        _photo = null;
        _photoKey++;
        _urgency = 'Media';
      });
      widget.onSent?.call();
    } on ApiException catch (e) {
      if (!mounted) return;
      showSnack(context, e.message, error: true);
    } catch (_) {
      if (!mounted) return;
      showSnack(context, 'No se pudo enviar el reporte', error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        const TabHeader(title: 'Reportar animal', subtitle: 'Cuéntanos qué viste'),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SlideFadeIn(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tipo de animal',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      OptionChips(
                        options: const ['Perro', 'Gato', 'Otro'],
                        selected: _species,
                        icons: const {
                          'Perro': Icons.pets,
                          'Gato': Icons.cruelty_free_rounded,
                          'Otro': Icons.emoji_nature_rounded,
                        },
                        onSelected: (v) => setState(() => _species = v),
                      ),
                      const SizedBox(height: 16),
                      const Text('Urgencia', style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      OptionChips(
                        options: const ['Baja', 'Media', 'Alta', 'Crítica'],
                        selected: _urgency,
                        colorOf: urgencyColor,
                        onSelected: (v) => setState(() => _urgency = v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SlideFadeIn(
                index: 1,
                child: PhotoPickerField(
                  key: ValueKey(_photoKey),
                  onChanged: (b) => _photo = b,
                ),
              ),
              const SizedBox(height: 14),
              SlideFadeIn(
                index: 2,
                child: TextFormField(
                  controller: _description,
                  maxLines: 4,
                  maxLength: 1000,
                  decoration: fieldDecoration('Describe la situación',
                      icon: Icons.edit_note_rounded,
                      hint: 'Estado del animal, color, tamaño, referencias...'),
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Describe con al menos 10 caracteres'
                      : null,
                ),
              ),
              const SizedBox(height: 6),
              SlideFadeIn(
                index: 3,
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(_gpsOk ? Icons.my_location_rounded : Icons.location_off_rounded,
                          color: _gpsOk ? AppColors.success : AppColors.warning),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _locating
                              ? 'Obteniendo tu ubicación...'
                              : _gpsOk
                                  ? 'Ubicación detectada'
                                  : 'Sin GPS: se usará una ubicación aproximada',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: _locating ? null : _locate,
                        child: const Text('Actualizar'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Enviar alerta',
                icon: Icons.notifications_active_rounded,
                kind: AppButtonKind.accent,
                loading: _sending,
                onPressed: _send,
              ),
              if (widget.onCancel != null) ...[
                const SizedBox(height: 8),
                AppButton(
                  label: 'Cancelar y volver al inicio',
                  kind: AppButtonKind.outline,
                  onPressed: _sending ? null : widget.onCancel,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

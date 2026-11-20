import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../services/reports_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _descCtrl = TextEditingController();
  final _reportsService = ReportsService();
  final ImagePicker _picker = ImagePicker();

  String _species = 'Perro';
  String _urgency = 'Media';
  double? _latitude;
  double? _longitude;
  Uint8List? _imageBytes;
  String? _photoBase64;
  bool _loadingGps = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _loadingGps = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('GPS desactivado');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Permiso denegado');
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      if (!mounted) return;
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _loadingGps = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _latitude = 21.1561;
        _longitude = -100.9308;
        _loadingGps = false;
      });
    }
  }

  Future<void> _handleCameraPressed() async {
    if (kIsWeb) {
      try {
        final cameras = await availableCameras();
        if (cameras.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se detectó ninguna cámara en este equipo')),
          );
          return;
        }

        if (!mounted) return;
        final Uint8List? capturedBytes = await showDialog<Uint8List>(
          context: context,
          builder: (context) => _WebCameraDialog(camera: cameras.first),
        );

        if (capturedBytes != null && mounted) {
          setState(() {
            _imageBytes = capturedBytes;
            _photoBase64 = base64Encode(capturedBytes);
          });
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al acceder a la cámara: $e')),
        );
      }
    } else {
      await _pickImage(ImageSource.camera);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 70,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _photoBase64 = base64Encode(bytes);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar la imagen')),
      );
    }
  }

  Future<void> _submitReport() async {
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor describe la situación del animal'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    final ok = await _reportsService.createReport(
      species: _species,
      urgency: _urgency,
      description: _descCtrl.text.trim(),
      latitude: _latitude ?? 21.1561,
      longitude: _longitude ?? -100.9308,
      photoBase64: _photoBase64,
    );
    setState(() => _submitting = false);

    if (!mounted) return;

    if (ok) {
      _descCtrl.clear();
      setState(() {
        _imageBytes = null;
        _photoBase64 = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Reporte enviado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar el reporte. Revisa el servidor.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Reportar Animal en Riesgo',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Vista previa de foto
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: _imageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Sin fotografía seleccionada'),
                    ],
                  ),
          ),
          const SizedBox(height: 12),

          // Botones de Cámara y Galería
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _handleCameraPressed,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cámara'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tarjeta de Ubicación GPS
          Card(
            color: Colors.teal.shade50,
            child: ListTile(
              leading: const Icon(Icons.location_on, color: Colors.teal),
              title: const Text('Ubicación GPS'),
              subtitle: _loadingGps
                  ? const Text('Obteniendo coordenadas...')
                  : Text(
                      'Lat: ${_latitude?.toStringAsFixed(5)} | Lon: ${_longitude?.toStringAsFixed(5)}',
                    ),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _getCurrentLocation,
                tooltip: 'Actualizar ubicación',
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Selector de Especie
          DropdownButtonFormField<String>(
            initialValue: _species,
            decoration: const InputDecoration(
              labelText: 'Especie',
              border: OutlineInputBorder(),
            ),
            items: ['Perro', 'Gato', 'Otro']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) => setState(() => _species = val!),
          ),
          const SizedBox(height: 16),

          // Selector de Urgencia
          DropdownButtonFormField<String>(
            initialValue: _urgency,
            decoration: const InputDecoration(
              labelText: 'Nivel de Urgencia',
              border: OutlineInputBorder(),
            ),
            items: ['Baja', 'Media', 'Alta', 'Crítica']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) => setState(() => _urgency = val!),
          ),
          const SizedBox(height: 16),

          // Descripción
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción y señas particulares',
              hintText: 'Ej. Perrito café herido cerca del parque...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          // Botón Enviar
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.send),
              label: _submitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Enviar Reporte de Rescate'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebCameraDialog extends StatefulWidget {
  final CameraDescription camera;
  const _WebCameraDialog({required this.camera});

  @override
  State<_WebCameraDialog> createState() => _WebCameraDialogState();
}

class _WebCameraDialogState extends State<_WebCameraDialog> {
  late CameraController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _initialized = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_controller.value.isInitialized) return;
    final XFile file = await _controller.takePicture();
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    Navigator.of(context).pop(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Capturar Fotografía'),
      content: SizedBox(
        width: 400,
        height: 300,
        child: _initialized
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CameraPreview(_controller),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _initialized ? _takePicture : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.camera),
          label: const Text('Tomar Foto'),
        ),
      ],
    );
  }
}
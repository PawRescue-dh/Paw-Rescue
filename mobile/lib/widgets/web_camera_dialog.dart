import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Cámara en vivo para la versión web (Chrome).
class WebCameraDialog extends StatefulWidget {
  final CameraDescription camera;
  const WebCameraDialog({super.key, required this.camera});

  @override
  State<WebCameraDialog> createState() => _WebCameraDialogState();
}

class _WebCameraDialogState extends State<WebCameraDialog> {
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: const Text('Capturar fotografía'),
      content: SizedBox(
        width: 400,
        height: 300,
        child: _initialized
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
            backgroundColor: AppColors.blue,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.camera),
          label: const Text('Tomar foto'),
        ),
      ],
    );
  }
}

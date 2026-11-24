import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme.dart';
import 'common.dart';
import 'web_camera_dialog.dart';

/// Campo para tomar o elegir una foto, con vista previa.
class PhotoPickerField extends StatefulWidget {
  final ValueChanged<Uint8List?> onChanged;
  final double height;
  final String label;

  const PhotoPickerField({
    super.key,
    required this.onChanged,
    this.height = 190,
    this.label = 'Toca para tomar una foto o elegir una',
  });

  @override
  State<PhotoPickerField> createState() => _PhotoPickerFieldState();
}

class _PhotoPickerFieldState extends State<PhotoPickerField> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _bytes;

  void _set(Uint8List? bytes) {
    setState(() => _bytes = bytes);
    widget.onChanged(bytes);
  }

  Future<void> _chooseSource() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: AppColors.blue),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.of(ctx).pop('camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.blue),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.of(ctx).pop('gallery'),
            ),
            if (_bytes != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                title: const Text('Quitar foto'),
                onTap: () => Navigator.of(ctx).pop('remove'),
              ),
            ListTile(
              leading: const Icon(Icons.close_rounded),
              title: const Text('Cancelar'),
              onTap: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    if (choice == 'remove') {
      _set(null);
    } else if (choice == 'gallery') {
      await _pick(ImageSource.gallery);
    } else {
      await _camera();
    }
  }

  Future<void> _camera() async {
    if (!kIsWeb) {
      await _pick(ImageSource.camera);
      return;
    }
    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        showSnack(context, 'No se detectó ninguna cámara en este equipo', error: true);
        return;
      }
      final Uint8List? captured = await showDialog<Uint8List>(
        context: context,
        builder: (ctx) => WebCameraDialog(camera: cameras.first),
      );
      if (captured != null && mounted) _set(captured);
    } catch (_) {
      if (!mounted) return;
      showSnack(context, 'No se pudo acceder a la cámara', error: true);
    }
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 70,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      _set(bytes);
    } catch (_) {
      if (!mounted) return;
      showSnack(context, 'No se pudo cargar la imagen', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    return GestureDetector(
      onTap: _chooseSource,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.blue.withValues(alpha: 0.45),
            width: 1.6,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: bytes != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(bytes, fit: BoxFit.cover),
                    const Positioned(
                      right: 10,
                      top: 10,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.edit_rounded, size: 16, color: AppColors.blue),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.photo_camera_rounded, size: 46, color: AppColors.blue),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

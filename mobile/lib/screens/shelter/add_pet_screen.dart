import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/format.dart';
import '../../services/auth_service.dart';
import '../../services/pets_service.dart';
import '../../widgets/common.dart';
import '../../widgets/photo_picker.dart';

/// Publicar una mascota en el tablero de adopción. Devuelve true si se publicó.
class AddPetScreen extends StatefulWidget {
  final UserSession session;
  const AddPetScreen({super.key, required this.session});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _description = TextEditingController();
  final _health = TextEditingController();
  late final TextEditingController _phone;
  final _service = PetsService();
  String _species = 'Perro';
  String _sex = 'Macho';
  String _size = 'Mediano';
  Uint8List? _photo;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController(text: widget.session.phone ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _description.dispose();
    _health.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _service.createPet(
        name: _name.text.trim(),
        species: _species,
        age: _age.text.trim(),
        sex: _sex,
        size: _size,
        description: _description.text.trim(),
        health: _health.text.trim(),
        shelterPhone: _phone.text.trim(),
        photoBase64: _photo == null ? null : base64Encode(_photo!),
      );
      if (!mounted) return;
      showSnack(context, '¡Mascota publicada en el tablero!');
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      showSnack(context, e.message, error: true);
    } catch (_) {
      if (!mounted) return;
      showSnack(context, 'No se pudo publicar la mascota', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlobBackground(
        child: SafeArea(
          child: Column(
            children: [
              const ScreenHeader(title: 'Publicar mascota', subtitle: 'Aparecerá en el tablero de adopción'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PhotoPickerField(onChanged: (b) => _photo = b, label: 'Toca para agregar la foto de la mascota'),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          decoration: fieldDecoration('Nombre', icon: Icons.pets),
                          validator: _required,
                        ),
                        const SizedBox(height: 12),
                        const Text('Especie', style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        OptionChips(
                          options: const ['Perro', 'Gato', 'Otro'],
                          selected: _species,
                          onSelected: (v) => setState(() => _species = v),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _age,
                          decoration: fieldDecoration('Edad (ej. 2 años)', icon: Icons.cake_outlined),
                          validator: _required,
                        ),
                        const SizedBox(height: 12),
                        const Text('Sexo', style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        OptionChips(
                          options: const ['Macho', 'Hembra'],
                          selected: _sex,
                          onSelected: (v) => setState(() => _sex = v),
                        ),
                        const SizedBox(height: 12),
                        const Text('Tamaño', style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        OptionChips(
                          options: const ['Pequeño', 'Mediano', 'Grande'],
                          selected: _size,
                          onSelected: (v) => setState(() => _size = v),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _description,
                          maxLines: 3,
                          decoration: fieldDecoration('Descripción y carácter', icon: Icons.notes_rounded),
                          validator: _required,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _health,
                          maxLines: 2,
                          decoration: fieldDecoration('Salud (vacunas, esterilización...)',
                              icon: Icons.health_and_safety_outlined),
                          validator: _required,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          decoration: fieldDecoration('Teléfono de contacto del albergue',
                              icon: Icons.phone_outlined),
                          validator: (v) =>
                              (v == null || !isValidPhone(v)) ? 'Ingresa un teléfono válido' : null,
                        ),
                        const SizedBox(height: 18),
                        AppButton(
                          label: 'Publicar en el tablero',
                          icon: Icons.upload_rounded,
                          kind: AppButtonKind.accent,
                          loading: _saving,
                          onPressed: _save,
                        ),
                        const SizedBox(height: 8),
                        AppButton(
                          label: 'Cancelar',
                          kind: AppButtonKind.outline,
                          onPressed: _saving ? null : () => Navigator.of(context).maybePop(),
                        ),
                      ],
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
}

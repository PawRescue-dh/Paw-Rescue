import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/pets_service.dart';
import '../../widgets/common.dart';

/// Detalle de una mascota en adopción. Devuelve true si se envió una solicitud.
class PetDetailScreen extends StatefulWidget {
  final Pet pet;
  final UserSession session;
  const PetDetailScreen({super.key, required this.pet, required this.session});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  final _service = PetsService();
  bool _sending = false;

  Future<void> _adopt() async {
    final phone = TextEditingController(text: widget.session.phone ?? '');
    final message = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Adoptar a ${widget.pet.name}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('El albergue recibirá tus datos de contacto para continuar el proceso.',
                    style: TextStyle(color: AppColors.muted)),
                const SizedBox(height: 14),
                TextFormField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: fieldDecoration('Tu teléfono', icon: Icons.phone_outlined),
                  validator: (v) =>
                      (v == null || !isValidPhone(v)) ? 'Ingresa un teléfono válido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: message,
                  maxLines: 3,
                  maxLength: 300,
                  decoration: fieldDecoration('Mensaje para el albergue (opcional)',
                      icon: Icons.chat_bubble_outline_rounded),
                ),
                const SizedBox(height: 8),
                AppButton(
                  label: 'Enviar solicitud',
                  icon: Icons.favorite_rounded,
                  kind: AppButtonKind.accent,
                  onPressed: () {
                    if (formKey.currentState!.validate()) Navigator.of(ctx).pop(true);
                  },
                ),
                const SizedBox(height: 8),
                AppButton(
                  label: 'Cancelar',
                  kind: AppButtonKind.outline,
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final phoneText = phone.text.trim();
    final messageText = message.text.trim();
    phone.dispose();
    message.dispose();
    if (confirmed != true || !mounted) return;

    setState(() => _sending = true);
    try {
      await _service.adopt(widget.pet.id, phoneText, messageText);
      if (!mounted) return;
      showSnack(context, '¡Solicitud enviada! El albergue se pondrá en contacto contigo.');
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      showSnack(context, e.message, error: true);
    } catch (_) {
      if (!mounted) return;
      showSnack(context, 'No se pudo enviar la solicitud', error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;
    return Scaffold(
      body: BlobBackground(
        child: SafeArea(
          child: Column(
            children: [
              ScreenHeader(title: pet.name, subtitle: '${pet.species} · ${pet.age}'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  children: [
                    SlideFadeIn(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: SizedBox(
                          height: 260,
                          child: PetPhoto(base64: pet.photoBase64, height: 260),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SlideFadeIn(
                      index: 1,
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                StatusChip(
                                    text: pet.status,
                                    color: petStatusColor(pet.status),
                                    icon: Icons.favorite_rounded),
                                StatusChip(text: pet.sex, color: AppColors.blue),
                                StatusChip(text: 'Tamaño ${pet.size.toLowerCase()}', color: AppColors.muted),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text('Sobre él o ella',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(pet.description, style: const TextStyle(height: 1.4)),
                            const SizedBox(height: 12),
                            const Text('Salud',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(pet.health, style: const TextStyle(height: 1.4)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SlideFadeIn(
                      index: 2,
                      child: AppCard(
                        child: Column(
                          children: [
                            InfoRow(
                                icon: Icons.home_work_rounded,
                                label: 'Albergue',
                                value: pet.shelterName),
                            InfoRow(
                                icon: Icons.phone_rounded,
                                label: 'Teléfono del albergue',
                                value: pet.shelterPhone,
                                copyable: true),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    AppButton(
                      label: 'Quiero adoptarlo',
                      icon: Icons.favorite_rounded,
                      kind: AppButtonKind.accent,
                      loading: _sending,
                      onPressed: pet.status == 'Disponible' ? _adopt : null,
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      label: 'Contactar al albergue',
                      icon: Icons.phone_in_talk_rounded,
                      kind: AppButtonKind.outline,
                      onPressed: () => copyToClipboard(context, pet.shelterPhone,
                          label: 'Teléfono copiado, llámalos para conocerlo'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

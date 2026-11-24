import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

/// Aviso de privacidad. Si se abre con [askAccept], devuelve true al aceptar.
class PrivacyScreen extends StatelessWidget {
  final bool askAccept;
  const PrivacyScreen({super.key, this.askAccept = false});

  static const List<List<String>> _sections = [
    [
      'Responsable',
      'PawRescue, proyecto del equipo Desarrollo Nakama (UTNG), es responsable del tratamiento de tus datos personales.',
    ],
    [
      'Datos que recabamos',
      'Nombre, correo electrónico, teléfono, ubicación aproximada al reportar un animal, fotografías que tú decidas enviar y los mensajes o solicitudes de adopción que realices.',
    ],
    [
      'Para qué los usamos',
      'Para crear tu cuenta, atender los reportes de animales en situación de calle, gestionar solicitudes de adopción y permitir que el albergue se ponga en contacto contigo.',
    ],
    [
      'Con quién se comparten',
      'Solo con los albergues registrados en la aplicación, únicamente cuando reportas un animal o solicitas adoptar una mascota. No vendemos ni cedemos tus datos a terceros.',
    ],
    [
      'Tu ubicación',
      'Solo se toma cuando capturas un reporte y se guarda junto con él para que el albergue pueda llegar al lugar.',
    ],
    [
      'Tus derechos',
      'Puedes solicitar acceso, corrección o eliminación de tus datos escribiendo al albergue o al equipo de PawRescue.',
    ],
    [
      'Seguridad',
      'Tu contraseña se guarda cifrada y la comunicación con el servidor viaja protegida.',
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlobBackground(
        child: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: 'Aviso de privacidad',
                subtitle: 'Tu información está protegida',
                showHome: false,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  children: [
                    for (int i = 0; i < _sections.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SlideFadeIn(
                          index: i,
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.verified_user_rounded,
                                        size: 18, color: AppColors.blue),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _sections[i][0],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: AppColors.text),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(_sections[i][1],
                                    style: const TextStyle(color: AppColors.muted, height: 1.4)),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: askAccept
                    ? Column(
                        children: [
                          AppButton(
                            label: 'Acepto el aviso de privacidad',
                            icon: Icons.check_circle_rounded,
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                          const SizedBox(height: 8),
                          AppButton(
                            label: 'Cancelar',
                            kind: AppButtonKind.outline,
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                        ],
                      )
                    : AppButton(
                        label: 'Cerrar',
                        icon: Icons.close_rounded,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

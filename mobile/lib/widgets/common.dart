import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/nav.dart';
import '../core/theme.dart';

/// Logotipo de PawRescue (huella + nombre en dos colores).
class PawLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool light;

  const PawLogo({super.key, this.size = 64, this.showText = true, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.blue.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(Icons.pets, size: size * 0.55, color: AppColors.blue),
        ),
        if (showText) ...[
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Paw',
                  style: TextStyle(
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.w800,
                    color: light ? Colors.white : AppColors.blue,
                  ),
                ),
                TextSpan(
                  text: 'Rescue',
                  style: TextStyle(
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.w800,
                    color: light ? AppColors.yellow : AppColors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob(this.size, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.75),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Fondo crema con manchas de colores, como en el diseño.
class BlobBackground extends StatelessWidget {
  final Widget child;
  const BlobBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: AppColors.cream)),
        const Positioned(top: -70, left: -60, child: _Blob(190, AppColors.pink)),
        const Positioned(top: -40, right: -80, child: _Blob(210, AppColors.blueLight)),
        const Positioned(bottom: -90, right: -50, child: _Blob(230, AppColors.peach)),
        const Positioned(bottom: 140, left: -80, child: _Blob(160, AppColors.mint)),
        child,
      ],
    );
  }
}

enum AppButtonKind { primary, accent, outline, danger }

class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expand;
  final AppButtonKind kind;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.expand = true,
    this.kind = AppButtonKind.primary,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.blue;
    Color fg = Colors.white;
    if (kind == AppButtonKind.accent) {
      bg = AppColors.yellow;
      fg = AppColors.text;
    } else if (kind == AppButtonKind.danger) {
      bg = AppColors.danger;
    }

    final content = loading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: kind == AppButtonKind.outline ? AppColors.blue : fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ],
          );

    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
    final Widget button;
    if (kind == AppButtonKind.outline) {
      button = OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blue,
          minimumSize: const Size(0, 52),
          shape: shape,
          side: const BorderSide(color: AppColors.blue, width: 1.5),
        ),
        child: content,
      );
    } else {
      button = ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          minimumSize: const Size(0, 52),
          elevation: 3,
          shadowColor: bg.withValues(alpha: 0.5),
          shape: shape,
        ),
        child: content,
      );
    }
    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

InputDecoration fieldDecoration(String label, {IconData? icon, Widget? suffix, String? hint}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: AppColors.line),
  );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: icon == null ? null : Icon(icon, color: AppColors.blue),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border,
    enabledBorder: border,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.blue, width: 2),
    ),
  );
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const StatusChip({super.key, required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Selector de opciones con "chips" (especie, urgencia, filtros...).
class OptionChips extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final Map<String, IconData> icons;
  final Color Function(String option)? colorOf;

  const OptionChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.icons = const {},
    this.colorOf,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selected;
        final color = colorOf == null ? AppColors.blue : colorOf!(option);
        final icon = icons[option];
        return ChoiceChip(
          label: Text(
            option,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          avatar: icon == null
              ? null
              : Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.muted),
          selected: isSelected,
          selectedColor: color,
          backgroundColor: Colors.white,
          showCheckmark: false,
          side: BorderSide(color: isSelected ? color : AppColors.line),
          shape: const StadiumBorder(),
          onSelected: (_) => onSelected(option),
        );
      }).toList(),
    );
  }
}

/// Imagen guardada como base64 (se decodifica una sola vez).
class Base64Image extends StatefulWidget {
  final String? data;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget placeholder;

  const Base64Image({
    super.key,
    required this.data,
    required this.placeholder,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  State<Base64Image> createState() => _Base64ImageState();
}

class _Base64ImageState extends State<Base64Image> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(covariant Base64Image oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) _decode();
  }

  void _decode() {
    final data = widget.data;
    if (data == null || data.isEmpty) {
      _bytes = null;
      return;
    }
    try {
      _bytes = base64Decode(data);
    } catch (_) {
      _bytes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    if (bytes == null) return widget.placeholder;
    return Image.memory(
      bytes,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => widget.placeholder,
    );
  }
}

/// Foto de mascota o, si no hay, una ilustración con huella.
class PetPhoto extends StatelessWidget {
  final String? base64;
  final double? height;
  final double? width;
  final IconData icon;

  const PetPhoto({super.key, required this.base64, this.height, this.width, this.icon = Icons.pets});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blueLight, AppColors.pink],
        ),
      ),
      child: Center(
        child: Icon(icon, size: 44, color: AppColors.blue.withValues(alpha: 0.55)),
      ),
    );
    return Base64Image(
      data: base64,
      height: height,
      width: width,
      placeholder: placeholder,
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(color: AppColors.blueLight, shape: BoxShape.circle),
              child: Icon(icon, size: 42, color: AppColors.blue),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  final String message;
  const LoadingView({super.key, this.message = 'Cargando...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.blue),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.cloud_off_rounded,
      title: 'No pudimos cargar la información',
      subtitle: message,
      action: AppButton(
        label: 'Reintentar',
        icon: Icons.refresh_rounded,
        expand: false,
        onPressed: onRetry,
      ),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const RoundIconButton({super.key, required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 2,
        shadowColor: Colors.black26,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 20, color: AppColors.text),
          ),
        ),
      ),
    );
  }
}

/// Encabezado de pantallas secundarias: botón volver, título y botón de inicio.
class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showHome;
  final Widget? trailing;
  final VoidCallback? onBack;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showHome = true,
    this.trailing,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          RoundIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'Volver',
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
          if (showHome)
            RoundIconButton(
              icon: Icons.home_rounded,
              tooltip: 'Ir al inicio',
              onTap: () => AppNav.goHome(context),
            ),
        ],
      ),
    );
  }
}

/// Encabezado de las pestañas principales.
class TabHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const TabHeader({super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.text),
                ),
                if (subtitle != null)
                  Text(subtitle!, style: const TextStyle(fontSize: 14, color: AppColors.muted)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Aparece con fundido y deslizamiento; `index` escalona las listas.
class SlideFadeIn extends StatelessWidget {
  final Widget child;
  final int index;
  final double dy;

  const SlideFadeIn({super.key, required this.child, this.index = 0, this.dy = 24});

  @override
  Widget build(BuildContext context) {
    final extra = index.clamp(0, 8).toInt() * 90;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + extra),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, (1 - value) * dy), child: child),
      ),
      child: child,
    );
  }
}

void showSnack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Aceptar',
  String cancelLabel = 'Cancelar',
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: danger ? AppColors.danger : AppColors.blue,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result == true;
}

Future<void> copyToClipboard(BuildContext context, String text, {String label = 'Copiado'}) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  showSnack(context, label);
}

/// Fila con icono, etiqueta y valor (opcionalmente copiable).
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool copyable;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.blueLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: AppColors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                Text(
                  value.isEmpty ? 'No disponible' : value,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.text),
                ),
              ],
            ),
          ),
          if (copyable && value.isNotEmpty)
            IconButton(
              tooltip: 'Copiar',
              icon: const Icon(Icons.copy_rounded, size: 20, color: AppColors.blue),
              onPressed: () => copyToClipboard(context, value, label: '$label copiado'),
            ),
        ],
      ),
    );
  }
}

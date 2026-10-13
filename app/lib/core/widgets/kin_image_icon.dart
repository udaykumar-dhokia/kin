import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class KinImageIcon extends StatelessWidget {
  final String? assetPath;
  final IconData fallbackIcon;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  const KinImageIcon({
    super.key,
    this.assetPath,
    required this.fallbackIcon,
    this.size = 42,
    this.iconSize = 20,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.muted;
    final fg = iconColor ?? theme.colorScheme.foreground;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.border.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: assetPath != null && assetPath!.isNotEmpty
            ? Image.asset(
                assetPath!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallback(fg),
              )
            : _buildFallback(fg),
      ),
    );
  }

  Widget _buildFallback(Color fg) {
    return Center(
      child: Icon(
        fallbackIcon,
        size: iconSize,
        color: fg,
      ),
    );
  }
}

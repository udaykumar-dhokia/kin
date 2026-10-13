import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EmptyStateIllustration extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? assetPath;
  final Widget? action;

  const EmptyStateIllustration({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = LucideIcons.circleCheck,
    this.assetPath,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Visual Slot (Image asset or vector fallback)
          Container(
            width: 120,
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.colorScheme.border),
            ),
            child: assetPath != null && assetPath!.isNotEmpty
                ? Image.asset(
                    assetPath!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallbackBadge(theme),
                  )
                : _buildFallbackBadge(theme),
          ),
          const SizedBox(height: 18),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.h4.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.muted.copyWith(fontSize: 14),
            ),
          ),

          if (action != null) ...[
            const SizedBox(height: 20),
            action!,
          ],
        ],
      ),
    );
  }

  Widget _buildFallbackBadge(ShadThemeData theme) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 26,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

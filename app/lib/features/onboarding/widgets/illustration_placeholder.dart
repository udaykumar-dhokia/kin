import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../models/onboarding_slide.dart';

class IllustrationPlaceholder extends StatelessWidget {
  final OnboardingSlide slide;

  const IllustrationPlaceholder({
    super.key,
    required this.slide,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    // If an image asset is provided later, render the asset directly.
    if (slide.imageAssetPath != null && slide.imageAssetPath!.isNotEmpty) {
      return Image.asset(
        slide.imageAssetPath!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholderFrame(context, theme),
      );
    }

    return _buildPlaceholderFrame(context, theme);
  }

  Widget _buildPlaceholderFrame(BuildContext context, ShadThemeData theme) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 280),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.border,
          width: 1.2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle decorative concentric background rings
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.border.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.border.withValues(alpha: 0.8),
                width: 1,
              ),
            ),
          ),

          // Central Icon & Illustration slot
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: theme.colorScheme.background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: theme.colorScheme.border,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    slide.icon,
                    size: 34,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Illustration slot',
                style: theme.textTheme.muted.copyWith(
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

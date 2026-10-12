import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum AuthIllustrationType {
  welcome,
  login,
  register,
}

class AuthIllustrationHeader extends StatelessWidget {
  final AuthIllustrationType type;
  final String? imageAssetPath;

  const AuthIllustrationHeader({
    super.key,
    required this.type,
    this.imageAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    // If custom artwork asset path is provided, attempt to render it
    if (imageAssetPath != null && imageAssetPath!.isNotEmpty) {
      return Container(
        height: 140,
        alignment: Alignment.center,
        child: Image.asset(
          imageAssetPath!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              _buildVectorBadge(context, theme),
        ),
      );
    }

    return _buildVectorBadge(context, theme);
  }

  Widget _buildVectorBadge(BuildContext context, ShadThemeData theme) {
    final (IconData icon, String label) = switch (type) {
      AuthIllustrationType.welcome => (
          LucideIcons.checkCheck,
          'Kin Illustration Slot',
        ),
      AuthIllustrationType.login => (
          LucideIcons.keyRound,
          'Sign In Illustration Slot',
        ),
      AuthIllustrationType.register => (
          LucideIcons.userCheck,
          'Sign Up Illustration Slot',
        ),
    };

    return Container(
      width: double.infinity,
      height: 140,
      margin: const EdgeInsets.only(bottom: 24),
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
          // Ambient concentric rings
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.border.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.border.withValues(alpha: 0.8),
                width: 1,
              ),
            ),
          ),

          // Central glyph container
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: theme.colorScheme.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.border,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 26,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.muted.copyWith(
                  fontSize: 11,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

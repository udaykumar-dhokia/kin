import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/widgets/kin_image_icon.dart';
import '../models/super_app_category.dart';

class CategoryCard extends StatelessWidget {
  final SuperAppCategory category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: category.isAvailable
                ? theme.colorScheme.border
                : theme.colorScheme.border.withValues(alpha: 0.6),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top row: Icon + Availability Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KinImageIcon(
                  assetPath: category.assetPath,
                  fallbackIcon: category.icon,
                  size: 40,
                  iconSize: 20,
                ),
                if (category.isAvailable)
                  ShadBadge(
                    child: const Text(
                      'AVAILABLE',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  ShadBadge.outline(
                    child: const Text(
                      'SOON',
                      style: TextStyle(fontSize: 9),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Title & Description
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.muted.copyWith(
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

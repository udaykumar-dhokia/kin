import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OnboardingSlide {
  final String badge;
  final String title;
  final String description;
  final IconData icon;
  final String? imageAssetPath;

  const OnboardingSlide({
    required this.badge,
    required this.title,
    required this.description,
    required this.icon,
    this.imageAssetPath,
  });

  static List<OnboardingSlide> get slides => const [
        OnboardingSlide(
          badge: 'DEADLINES',
          title: 'Never miss what matters.',
          description:
              'Keep all your bills, renewals, and deadlines in one calm place.',
          icon: LucideIcons.calendarClock,
        ),
        OnboardingSlide(
          badge: 'HOUSEHOLD',
          title: 'Keep everyone in sync.',
          description:
              'Coordinate household tasks and bills with family effortlessly.',
          icon: LucideIcons.users,
        ),
        OnboardingSlide(
          badge: 'AUTOMATION',
          title: 'Set once. Relax forever.',
          description:
              'Recurring expenses and dates schedule themselves automatically.',
          icon: LucideIcons.repeat,
        ),
      ];
}

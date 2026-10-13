import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MetricSummaryCards extends StatelessWidget {
  final double totalAmount;
  final int activeCount;

  const MetricSummaryCards({
    super.key,
    required this.totalAmount,
    required this.activeCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Upcoming',
                  style: theme.textTheme.muted.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${totalAmount.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.h4.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Deadlines',
                  style: theme.textTheme.muted.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  '$activeCount items',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.h4.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

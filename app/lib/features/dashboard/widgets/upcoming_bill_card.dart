import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/widgets/kin_image_icon.dart';
import '../../bills/models/bill_model.dart';

class UpcomingBillCard extends StatelessWidget {
  final BillModel bill;
  final VoidCallback? onPay;

  const UpcomingBillCard({
    super.key,
    required this.bill,
    this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Icon (with 3D asset placeholder support)
              KinImageIcon(
                assetPath: bill.category.assetPath,
                fallbackIcon: bill.category.icon,
                size: 44,
                iconSize: 22,
              ),
              const SizedBox(width: 14),

              // Title and Due Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            bill.dueLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.muted.copyWith(fontSize: 13),
                          ),
                        ),
                        if (bill.isRecurring &&
                            bill.recurringFrequency != null) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '• ${bill.recurringFrequency!.toLowerCase()}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.muted.copyWith(fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Amount
              Text(
                '₹${bill.amount.toStringAsFixed(0)}',
                style: theme.textTheme.large.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Footer: Assigned member & Mark as Paid Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (bill.assignedMemberName != null)
                Row(
                  children: [
                    Icon(
                      LucideIcons.user,
                      size: 13,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      bill.assignedMemberName!,
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              else
                const SizedBox.shrink(),

              // Mark as Paid button
              ShadButton.outline(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                onPressed: onPay,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.check, size: 14),
                    SizedBox(width: 6),
                    Text('Mark Paid', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

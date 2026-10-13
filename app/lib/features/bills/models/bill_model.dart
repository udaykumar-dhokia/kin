import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum BillCategory {
  housing,
  utilities,
  insurance,
  vehicle,
  subscription,
  general;

  String get displayName => switch (this) {
        BillCategory.housing => 'Housing & Rent',
        BillCategory.utilities => 'Utilities',
        BillCategory.insurance => 'Insurance',
        BillCategory.vehicle => 'Vehicle',
        BillCategory.subscription => 'Subscriptions',
        BillCategory.general => 'General',
      };

  IconData get icon => switch (this) {
        BillCategory.housing => LucideIcons.house,
        BillCategory.utilities => LucideIcons.zap,
        BillCategory.insurance => LucideIcons.shieldCheck,
        BillCategory.vehicle => LucideIcons.car,
        BillCategory.subscription => LucideIcons.creditCard,
        BillCategory.general => LucideIcons.receipt,
      };

  String get assetPath => 'assets/images/cat_${name.toLowerCase()}.png';
}

enum BillStatus {
  pending,
  paid,
  overdue;

  String get displayName => switch (this) {
        BillStatus.pending => 'Pending',
        BillStatus.paid => 'Paid',
        BillStatus.overdue => 'Overdue',
      };
}

class BillModel {
  final String id;
  final String title;
  final double amount;
  final String currency;
  final DateTime dueDate;
  final BillCategory category;
  final BillStatus status;
  final bool isRecurring;
  final String? recurringFrequency;
  final String? assignedMemberName;
  final String? notes;

  const BillModel({
    required this.id,
    required this.title,
    required this.amount,
    this.currency = 'INR',
    required this.dueDate,
    this.category = BillCategory.general,
    this.status = BillStatus.pending,
    this.isRecurring = false,
    this.recurringFrequency,
    this.assignedMemberName,
    this.notes,
  });

  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  int get daysUntilDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return target.difference(today).inDays;
  }

  String get dueLabel {
    final days = daysUntilDue;
    if (days < 0) return '${days.abs()}d overdue';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    return 'Due in $days days';
  }

  factory BillModel.fromJson(Map<String, dynamic> json) {
    BillCategory parseCategory(String? cat) {
      if (cat == null) return BillCategory.general;
      final upper = cat.toUpperCase();
      switch (upper) {
        case 'RENT':
        case 'HOUSING':
          return BillCategory.housing;
        case 'ELECTRICITY':
        case 'WATER':
        case 'INTERNET_BROADBAND':
        case 'GAS_UTILITY':
        case 'UTILITIES':
          return BillCategory.utilities;
        case 'INSURANCE_PREMIUM':
        case 'INSURANCE':
          return BillCategory.insurance;
        case 'SUBSCRIPTION':
          return BillCategory.subscription;
        case 'VEHICLE':
          return BillCategory.vehicle;
        default:
          return BillCategory.general;
      }
    }

    BillStatus parseStatus(String? st) {
      if (st == null) return BillStatus.pending;
      final lower = st.toLowerCase();
      return BillStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == lower,
        orElse: () => BillStatus.pending,
      );
    }

    return BillModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Bill',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      category: parseCategory(json['category'] as String?),
      status: parseStatus(json['status'] as String?),
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringFrequency: (json['recurrenceInterval'] ??
              json['recurringFrequency']) as String?,
      assignedMemberName: json['assignedMember']?['name'] as String? ??
          json['assignedMemberName'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

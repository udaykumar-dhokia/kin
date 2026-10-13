import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SuperAppCategory {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String assetPath;
  final bool isAvailable;
  final int? targetTabIndex; // If it maps to a live bottom-nav tab

  const SuperAppCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.assetPath,
    this.isAvailable = false,
    this.targetTabIndex,
  });

  static const List<SuperAppCategory> allCategories = [
    SuperAppCategory(
      id: 'bills_payments',
      title: 'Bills & Payments',
      description: 'Track utilities, rent, cards & scheduled deadlines',
      icon: LucideIcons.receipt,
      assetPath: 'assets/images/cat_bills.png',
      isAvailable: true,
      targetTabIndex: 2, // Live Bills tab
    ),
    SuperAppCategory(
      id: 'documents',
      title: 'Documents',
      description: 'Digital locker for IDs, warranty cards & vehicle RC',
      icon: LucideIcons.fileText,
      assetPath: 'assets/images/cat_documents.png',
      isAvailable: false,
    ),
    SuperAppCategory(
      id: 'insurance',
      title: 'Insurance',
      description: 'Health, motor, life & term insurance policy renewals',
      icon: LucideIcons.shieldCheck,
      assetPath: 'assets/images/cat_insurance.png',
      isAvailable: false,
    ),
    SuperAppCategory(
      id: 'vehicles',
      title: 'Vehicles',
      description: 'Service logs, PUC, FASTag & maintenance reminders',
      icon: LucideIcons.car,
      assetPath: 'assets/images/cat_vehicle.png',
      isAvailable: false,
    ),
    SuperAppCategory(
      id: 'home',
      title: 'Home',
      description: 'Rent agreements, appliance AMC & household inventory',
      icon: LucideIcons.house,
      assetPath: 'assets/images/cat_housing.png',
      isAvailable: false,
    ),
    SuperAppCategory(
      id: 'subscriptions',
      title: 'Subscriptions',
      description: 'Streaming, SaaS & recurring app renewals and audits',
      icon: LucideIcons.creditCard,
      assetPath: 'assets/images/cat_subscription.png',
      isAvailable: false,
    ),
    SuperAppCategory(
      id: 'family',
      title: 'Family',
      description: 'Shared household space, members & task delegation',
      icon: LucideIcons.users,
      assetPath: 'assets/images/cat_family.png',
      isAvailable: true,
      targetTabIndex: 3, // Live Family tab
    ),
    SuperAppCategory(
      id: 'maintenance',
      title: 'Maintenance',
      description: 'Plumbing, AC servicing, pest control & home repairs',
      icon: LucideIcons.wrench,
      assetPath: 'assets/images/cat_maintenance.png',
      isAvailable: false,
    ),
    SuperAppCategory(
      id: 'appointments',
      title: 'Appointments',
      description: 'Doctor checkups, vet visits & renewal appointments',
      icon: LucideIcons.calendar,
      assetPath: 'assets/images/cat_appointments.png',
      isAvailable: false,
    ),
    SuperAppCategory(
      id: 'recurring',
      title: 'Recurring',
      description: 'Automated recurring schedules & periodic obligations',
      icon: LucideIcons.refreshCw,
      assetPath: 'assets/images/cat_recurring.png',
      isAvailable: false,
    ),
  ];
}

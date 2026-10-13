import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/widgets/empty_state_illustration.dart';
import '../models/family_model.dart';
import '../services/family_service.dart';
import '../widgets/add_member_bottom_sheet.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _familyService = FamilyService();
  HouseholdModel? _household;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHousehold();
  }

  Future<void> _loadHousehold() async {
    setState(() => _isLoading = true);
    final h = await _familyService.getHousehold();
    if (mounted) {
      setState(() {
        _household = h;
        _isLoading = false;
      });
    }
  }

  void _openAddMemberSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMemberBottomSheet(
        onMemberAdded: (_) => _loadHousehold(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final household = _household;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : RefreshIndicator(
                onRefresh: _loadHousehold,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Bar
                      Text(
                        'Household',
                        style: theme.textTheme.h3.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Household Hero Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.colorScheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    household?.name ?? 'My Household',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.h4.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ShadBadge(
                                  child: Text(household?.currency ?? 'INR'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Shared responsibility space for bills, renewals, and deadlines.',
                              style: theme.textTheme.muted.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Members Section
                      Text(
                        'Members (${household?.members.length ?? 0})',
                        style: theme.textTheme.large.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (household != null && household.members.isNotEmpty)
                        ...household.members.map((member) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.colorScheme.border),
                            ),
                            child: Row(
                              children: [
                                // Avatar circle with initial
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      member.name.isNotEmpty
                                          ? member.name[0].toUpperCase()
                                          : 'M',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Name & relationship
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        member.relationship.toLowerCase(),
                                        style: theme.textTheme.muted
                                            .copyWith(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),

                                // Assigned Responsibilities Count Badge
                                ShadBadge.outline(
                                  child: Text(
                                    '${member.assignedCount} tasks',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                      else
                        const EmptyStateIllustration(
                          title: 'No members added yet',
                          subtitle:
                              'Tap the + button to add family members or dependents.',
                          icon: LucideIcons.users,
                        ),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddMemberSheet,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.primaryForeground,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tooltip: 'Add Family Member',
        child: const Icon(LucideIcons.userPlus, size: 22),
      ),
    );
  }
}

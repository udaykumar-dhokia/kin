import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../models/family_model.dart';
import '../services/family_service.dart';

class AddMemberBottomSheet extends StatefulWidget {
  final ValueChanged<HouseholdMemberModel>? onMemberAdded;

  const AddMemberBottomSheet({super.key, this.onMemberAdded});

  @override
  State<AddMemberBottomSheet> createState() => _AddMemberBottomSheetState();
}

class _AddMemberBottomSheetState extends State<AddMemberBottomSheet> {
  final _nameController = TextEditingController();
  final _familyService = FamilyService();
  String _relation = 'SPOUSE';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          title: Text('Name required'),
          description: Text('Please enter a member name.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final member = await _familyService.addMember(
        name: name,
        relationship: _relation,
      );

      if (!mounted) return;

      if (member != null && widget.onMemberAdded != null) {
        widget.onMemberAdded!(member);
      }

      Navigator.of(context).pop();

      ShadToaster.of(context).show(
        ShadToast(
          title: const Text('Member Added'),
          description: Text('$name added to household.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Failed to add member'),
          description: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Family Member',
                  style: theme.textTheme.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name
            Text('Full Name', style: theme.textTheme.small),
            const SizedBox(height: 6),
            ShadInput(
              controller: _nameController,
              placeholder: const Text('e.g. Priya, Rahul, Mom'),
            ),
            const SizedBox(height: 16),

            // Relationship Dropdown
            Text('Relationship', style: theme.textTheme.small),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _relation,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: const [
                DropdownMenuItem(value: 'SPOUSE', child: Text('Spouse')),
                DropdownMenuItem(value: 'FATHER', child: Text('Father')),
                DropdownMenuItem(value: 'MOTHER', child: Text('Mother')),
                DropdownMenuItem(value: 'SON', child: Text('Son')),
                DropdownMenuItem(value: 'DAUGHTER', child: Text('Daughter')),
                DropdownMenuItem(value: 'BROTHER', child: Text('Brother')),
                DropdownMenuItem(value: 'SISTER', child: Text('Sister')),
                DropdownMenuItem(value: 'OTHER', child: Text('Other')),
              ],
              onChanged: _isSubmitting
                  ? null
                  : (val) {
                      if (val != null) setState(() => _relation = val);
                    },
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ShadButton(
                onPressed: _isSubmitting ? null : _handleSave,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Member'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../family/models/family_model.dart';
import '../../family/services/family_service.dart';
import '../models/bill_model.dart';
import '../services/bills_service.dart';

class AddBillBottomSheet extends StatefulWidget {
  final ValueChanged<BillModel>? onBillCreated;

  const AddBillBottomSheet({super.key, this.onBillCreated});

  @override
  State<AddBillBottomSheet> createState() => _AddBillBottomSheetState();
}

class _AddBillBottomSheetState extends State<AddBillBottomSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _billsService = BillsService();
  final _familyService = FamilyService();

  BillCategory _selectedCategory = BillCategory.utilities;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isRecurring = false;
  String _frequency = 'MONTHLY';
  String? _selectedMemberId;
  String? _selectedMemberName;
  List<HouseholdMemberModel> _members = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHouseholdMembers();
  }

  Future<void> _loadHouseholdMembers() async {
    final household = await _familyService.getHousehold();
    if (mounted && household != null && household.members.isNotEmpty) {
      setState(() {
        _members = household.members;
        // Select the self/owner member by default if found
        final defaultMember = _members.firstWhere(
          (m) => m.role == 'OWNER' || m.relationship == 'SELF',
          orElse: () => _members.first,
        );
        _selectedMemberId = defaultMember.id;
        _selectedMemberName = defaultMember.name;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();

    if (title.isEmpty) {
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          title: Text('Title required'),
          description: Text('Please enter a description or bill name.'),
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText) ?? 0.0;
    if (amount <= 0) {
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          title: Text('Invalid amount'),
          description: Text('Please enter a valid amount greater than 0.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bill = await _billsService.createBill(
        title: title,
        amount: amount,
        dueDate: _dueDate,
        category: _selectedCategory,
        isRecurring: _isRecurring,
        recurringFrequency: _isRecurring ? _frequency : null,
        assignedMemberId: _selectedMemberId,
        assignedMemberName: _selectedMemberName,
      );

      if (!mounted) return;

      if (bill != null && widget.onBillCreated != null) {
        widget.onBillCreated!(bill);
      }

      Navigator.of(context).pop();

      ShadToaster.of(context).show(
        ShadToast(
          title: const Text('Deadline Added'),
          description: Text(
            '"$title" scheduled for ${_dueDate.day}/${_dueDate.month}.',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Failed to add bill'),
            description: Text(e.toString()),
          ),
        );
      }
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
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Deadline',
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

            // Title
            Text('Title', style: theme.textTheme.small),
            const SizedBox(height: 6),
            ShadInput(
              controller: _titleController,
              placeholder: const Text('e.g. Car Insurance, Electricity, Rent'),
            ),
            const SizedBox(height: 14),

            // Amount
            Text('Amount (₹)', style: theme.textTheme.small),
            const SizedBox(height: 6),
            ShadInput(
              controller: _amountController,
              placeholder: const Text('0.00'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              leading: const Padding(
                padding: EdgeInsets.only(left: 6, right: 6),
                child:
                    Text('₹', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 14),

            // Due Date
            Text('Due Date', style: theme.textTheme.small),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (picked != null) {
                  setState(() => _dueDate = picked);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colorScheme.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}'),
                    const Icon(LucideIcons.calendar, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Category Chips
            Text('Category', style: theme.textTheme.small),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: BillCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat.icon,
                              size: 14,
                              color: isSelected
                                  ? theme.colorScheme.primaryForeground
                                  : theme.colorScheme.foreground,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? theme.colorScheme.primaryForeground
                                    : theme.colorScheme.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Recurrence Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Repeating responsibility',
                        style: theme.textTheme.small),
                    Text(
                      'Auto-reschedules when marked paid',
                      style: theme.textTheme.muted.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                Switch(
                  value: _isRecurring,
                  onChanged: (val) => setState(() => _isRecurring = val),
                ),
              ],
            ),
            if (_isRecurring) ...[
              const SizedBox(height: 8),
              Row(
                children: ['MONTHLY', 'QUARTERLY', 'YEARLY'].map((freq) {
                  final isSel = _frequency == freq;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(freq.toLowerCase()),
                      selected: isSel,
                      onSelected: (_) => setState(() => _frequency = freq),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 14),

            // Assign To (Loaded dynamically from real household members)
            if (_members.isNotEmpty) ...[
              Text('Assign to Member', style: theme.textTheme.small),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _members.map((member) {
                    final isSel = _selectedMemberId == member.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(member.name),
                        selected: isSel,
                        onSelected: (_) => setState(() {
                          _selectedMemberId = member.id;
                          _selectedMemberName = member.name;
                        }),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ] else
              const SizedBox(height: 10),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ShadButton(
                onPressed: _isLoading ? null : _handleSave,
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Deadline'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

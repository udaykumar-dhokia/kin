import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/widgets/empty_state_illustration.dart';
import '../../../core/widgets/kin_image_icon.dart';
import '../models/bill_model.dart';
import '../services/bills_service.dart';
import '../widgets/add_bill_bottom_sheet.dart';

class BillsListScreen extends StatefulWidget {
  const BillsListScreen({super.key});

  @override
  State<BillsListScreen> createState() => _BillsListScreenState();
}

class _BillsListScreenState extends State<BillsListScreen> {
  final _billsService = BillsService();
  final _searchController = TextEditingController();

  List<BillModel> _allBills = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL'; // ALL, PENDING, PAID
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBills();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBills() async {
    setState(() => _isLoading = true);
    final bills = await _billsService.getBills();
    if (mounted) {
      setState(() {
        _allBills = bills;
        _isLoading = false;
      });
    }
  }

  List<BillModel> get _filteredBills {
    return _allBills.where((b) {
      // Status filter
      if (_selectedFilter == 'PENDING' && b.status == BillStatus.paid) {
        return false;
      }
      if (_selectedFilter == 'PAID' && b.status != BillStatus.paid) {
        return false;
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final matchesTitle = b.title.toLowerCase().contains(_searchQuery);
        final matchesCat =
            b.category.displayName.toLowerCase().contains(_searchQuery);
        return matchesTitle || matchesCat;
      }
      return true;
    }).toList();
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBillBottomSheet(
        onBillCreated: (newBill) {
          _loadBills();
        },
      ),
    );
  }

  Future<void> _handlePay(BillModel bill) async {
    await _billsService.markAsPaid(bill.id);
    if (!mounted) return;
    ShadToaster.of(context).show(
      ShadToast(
        title: const Text('Marked as Paid'),
        description: Text('${bill.title} marked as paid.'),
      ),
    );
    _loadBills();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final displayed = _filteredBills;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bills & Deadlines',
                  style: theme.textTheme.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: ShadInput(
                controller: _searchController,
                placeholder: const Text('Search by name or category...'),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 6, right: 8),
                  child: Icon(
                    LucideIcons.search,
                    size: 16,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: ['ALL', 'PENDING', 'PAID'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        filter[0] + filter.substring(1).toLowerCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Bills List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : displayed.isEmpty
                      ? const EmptyStateIllustration(
                          title: 'No bills found',
                          subtitle:
                              'Try adjusting your search or tap + Add to create a new deadline.',
                          icon: LucideIcons.receipt,
                          assetPath: 'assets/images/empty_bills.png',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          itemCount: displayed.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final bill = displayed[index];
                            final isPaid = bill.status == BillStatus.paid;

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.card,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  KinImageIcon(
                                    assetPath: bill.category.assetPath,
                                    fallbackIcon: bill.category.icon,
                                    size: 42,
                                    iconSize: 20,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bill.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            decoration: isPaid
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${bill.category.displayName} • ${bill.dueLabel}',
                                          style: theme.textTheme.muted
                                              .copyWith(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₹${bill.amount.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: isPaid
                                              ? theme.colorScheme.mutedForeground
                                              : theme.colorScheme.foreground,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      if (!isPaid)
                                        GestureDetector(
                                          onTap: () => _handlePay(bill),
                                          child: Text(
                                            'Pay now',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        )
                                      else
                                        ShadBadge(
                                          child: const Text(
                                            'PAID',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSheet,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.primaryForeground,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tooltip: 'Add Bill',
        child: const Icon(LucideIcons.plus, size: 22),
      ),
    );
  }
}

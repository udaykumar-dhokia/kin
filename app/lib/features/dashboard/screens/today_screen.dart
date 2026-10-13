import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/empty_state_illustration.dart';
import '../../bills/models/bill_model.dart';
import '../../bills/services/bills_service.dart';
import '../../bills/widgets/add_bill_bottom_sheet.dart';
import '../../family/models/family_model.dart';
import '../../family/services/family_service.dart';
import '../widgets/attention_hero_card.dart';
import '../widgets/metric_summary_cards.dart';
import '../widgets/upcoming_bill_card.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final _billsService = BillsService();
  final _familyService = FamilyService();

  bool _isLoading = true;
  DashboardResponse? _dashboardData;
  HouseholdModel? _household;
  String _userName = 'there';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final user = StorageService.getUserData();
    if (user != null && user['firstName'] != null) {
      _userName = user['firstName'] as String;
    }

    final dashboard = await _billsService.getDashboardData();
    final household = await _familyService.getHousehold();

    if (mounted) {
      setState(() {
        _dashboardData = dashboard;
        _household = household;
        _isLoading = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBillBottomSheet(
        onBillCreated: (newBill) {
          _loadData();
        },
      ),
    );
  }

  Future<void> _handlePay(BillModel bill) async {
    try {
      await _billsService.markAsPaid(bill.id);
      if (!mounted) return;
      ShadToaster.of(context).show(
        ShadToast(
          title: const Text('Marked as Paid'),
          description: Text(
            bill.isRecurring
                ? '${bill.title} paid! Next cycle scheduled automatically.'
                : '${bill.title} marked as completed.',
          ),
        ),
      );
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Payment failed'),
          description: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final data = _dashboardData;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Bar: Greeting
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()}, $_userName 👋',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.h3.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _household?.name ?? 'Personal Space',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.muted.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                LucideIcons.chevronDown,
                                size: 14,
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Attention Hero Card
                      AttentionHeroCard(
                        urgentItems: data?.urgentItems ?? [],
                        onBillTap: _handlePay,
                      ),
                      const SizedBox(height: 20),

                      // Metric Summary Cards
                      MetricSummaryCards(
                        totalAmount: data?.totalUpcomingAmount ?? 0,
                        activeCount: data?.activeCount ?? 0,
                      ),
                      const SizedBox(height: 28),

                      // Upcoming Schedule Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Upcoming Schedule',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.large.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${data?.upcomingItems.length ?? 0} upcoming',
                            style: theme.textTheme.muted.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // List of Upcoming Bills
                      if (data != null && data.upcomingItems.isNotEmpty)
                        ...data.upcomingItems.map(
                          (bill) => UpcomingBillCard(
                            bill: bill,
                            onPay: () => _handlePay(bill),
                          ),
                        )
                      else
                        const EmptyStateIllustration(
                          title: 'Nothing due soon',
                          subtitle:
                              'All upcoming obligations are clear. Tap + Add to schedule your next deadline.',
                          icon: LucideIcons.calendarCheck,
                        ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
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
        tooltip: 'Add Deadline',
        child: const Icon(LucideIcons.plus, size: 22),
      ),
    );
  }
}

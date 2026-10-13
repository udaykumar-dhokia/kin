import '../../../core/network/api_client.dart';
import '../models/bill_model.dart';

class DashboardResponse {
  final List<BillModel> urgentItems;
  final List<BillModel> upcomingItems;
  final double totalUpcomingAmount;
  final int activeCount;

  const DashboardResponse({
    required this.urgentItems,
    required this.upcomingItems,
    required this.totalUpcomingAmount,
    required this.activeCount,
  });
}

class BillsService {
  final ApiClient _client;

  BillsService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<DashboardResponse> getDashboardData() async {
    try {
      final response = await _client.get('/bills/dashboard');
      final dashboard = (response['dashboard'] as Map<String, dynamic>?) ??
          (response['data']?['dashboard'] as Map<String, dynamic>?) ??
          (response['data'] as Map<String, dynamic>?);

      if (dashboard != null) {
        final overdueList = (dashboard['overdue'] as List<dynamic>? ?? [])
            .map((b) => BillModel.fromJson(b as Map<String, dynamic>))
            .toList();
        final dueSoonList = (dashboard['dueSoon'] as List<dynamic>? ?? [])
            .map((b) => BillModel.fromJson(b as Map<String, dynamic>))
            .toList();
        final upcomingList = (dashboard['upcoming'] as List<dynamic>? ?? [])
            .map((b) => BillModel.fromJson(b as Map<String, dynamic>))
            .toList();

        final metrics = dashboard['metrics'] as Map<String, dynamic>? ??
            dashboard['summary'] as Map<String, dynamic>? ??
            {};

        final total = (metrics['totalPendingAmount'] is num)
            ? (metrics['totalPendingAmount'] as num).toDouble()
            : (metrics['totalUpcomingAmount'] is num)
                ? (metrics['totalUpcomingAmount'] as num).toDouble()
                : 0.0;

        final activeCount = (metrics['overdueCount'] as int? ?? 0) +
            (metrics['dueSoonCount'] as int? ?? 0) +
            (metrics['upcomingCount'] as int? ?? 0);

        final urgent = [...overdueList, ...dueSoonList];

        return DashboardResponse(
          urgentItems: urgent,
          upcomingItems: upcomingList,
          totalUpcomingAmount: total,
          activeCount: activeCount > 0 ? activeCount : (urgent.length + upcomingList.length),
        );
      }
    } catch (_) {
      // Return empty real-state on network or connection errors
    }

    return const DashboardResponse(
      urgentItems: [],
      upcomingItems: [],
      totalUpcomingAmount: 0.0,
      activeCount: 0,
    );
  }

  Future<List<BillModel>> getBills({BillStatus? statusFilter}) async {
    try {
      final endpoint = statusFilter != null
          ? '/bills?status=${statusFilter.name.toUpperCase()}'
          : '/bills';
      final response = await _client.get(endpoint);
      final rawList = (response['bills'] as List<dynamic>?) ??
          (response['data']?['bills'] as List<dynamic>?) ??
          (response['data'] as List<dynamic>?) ??
          [];

      return rawList
          .map((b) => BillModel.fromJson(b as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> markAsPaid(String billId) async {
    await _client.post('/bills/$billId/pay');
  }

  Future<BillModel?> createBill({
    required String title,
    required double amount,
    required DateTime dueDate,
    required BillCategory category,
    bool isRecurring = false,
    String? recurringFrequency,
    String? assignedMemberId,
    String? assignedMemberName,
    String? notes,
  }) async {
    final backendCategory = switch (category) {
      BillCategory.housing => 'RENT',
      BillCategory.utilities => 'ELECTRICITY',
      BillCategory.insurance => 'INSURANCE_PREMIUM',
      BillCategory.vehicle => 'OTHER',
      BillCategory.subscription => 'SUBSCRIPTION',
      BillCategory.general => 'OTHER',
    };

    final body = <String, dynamic>{
      'title': title,
      'amount': amount,
      'currency': 'INR',
      'dueDate': dueDate.toIso8601String(),
      'category': backendCategory,
      'isRecurring': isRecurring,
    };

    if (isRecurring && recurringFrequency != null && recurringFrequency.isNotEmpty) {
      body['recurrenceInterval'] = recurringFrequency;
    }
    if (assignedMemberId != null && assignedMemberId.isNotEmpty) {
      body['assignedMemberId'] = assignedMemberId;
    }
    if (notes != null && notes.isNotEmpty) {
      body['notes'] = notes;
    }

    final response = await _client.post(
      '/bills',
      body: body,
    );

    final billJson = (response['bill'] as Map<String, dynamic>?) ??
        (response['data']?['bill'] as Map<String, dynamic>?);
    if (billJson != null) {
      return BillModel.fromJson(billJson);
    }

    return null;
  }
}

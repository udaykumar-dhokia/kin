class HouseholdMemberModel {
  final String id;
  final String name;
  final String relationship;
  final String role;
  final String? avatarUrl;
  final int assignedCount;

  const HouseholdMemberModel({
    required this.id,
    required this.name,
    required this.relationship,
    this.role = 'MEMBER',
    this.avatarUrl,
    this.assignedCount = 0,
  });

  factory HouseholdMemberModel.fromJson(Map<String, dynamic> json) {
    return HouseholdMemberModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Member',
      relationship: json['relationship'] as String? ?? 'OTHER',
      role: json['role'] as String? ?? 'MEMBER',
      avatarUrl: json['avatarUrl'] as String?,
      assignedCount: json['_count']?['assignedBills'] as int? ??
          json['assignedCount'] as int? ??
          0,
    );
  }
}

class HouseholdModel {
  final String id;
  final String name;
  final String currency;
  final List<HouseholdMemberModel> members;

  const HouseholdModel({
    required this.id,
    required this.name,
    this.currency = 'INR',
    this.members = const [],
  });

  factory HouseholdModel.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'] as List<dynamic>? ?? [];
    return HouseholdModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'My Household',
      currency: json['currency'] as String? ?? 'INR',
      members: rawMembers
          .map((m) => HouseholdMemberModel.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

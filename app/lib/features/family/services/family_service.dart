import '../../../core/network/api_client.dart';
import '../models/family_model.dart';

class FamilyService {
  final ApiClient _client;

  FamilyService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<HouseholdModel?> getHousehold() async {
    try {
      final response = await _client.get('/family');
      final household = (response['household'] as Map<String, dynamic>?) ??
          (response['data']?['household'] as Map<String, dynamic>?);
      if (household != null) {
        return HouseholdModel.fromJson(household);
      }
    } catch (_) {
      // Return null or empty household on connection issue
    }

    return const HouseholdModel(
      id: '',
      name: 'My Household',
      currency: 'INR',
      members: [],
    );
  }

  Future<HouseholdMemberModel?> addMember({
    required String name,
    required String relationship,
    String role = 'MEMBER',
  }) async {
    final response = await _client.post(
      '/family/members',
      body: {
        'name': name,
        'relationship': relationship,
        'role': role,
      },
    );

    final memberJson = (response['member'] as Map<String, dynamic>?) ??
        (response['data']?['member'] as Map<String, dynamic>?);
    if (memberJson != null) {
      return HouseholdMemberModel.fromJson(memberJson);
    }
    return null;
  }
}

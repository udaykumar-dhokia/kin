import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _client;

  AuthService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final responseData = await _client.post(
      ApiConstants.login,
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
      withAuth: false,
    );

    final authResponse = AuthResponse.fromJson(responseData);
    await _persistSession(authResponse);
    return authResponse;
  }

  Future<AuthResponse> register({
    required String firstName,
    String? lastName,
    required String email,
    required String password,
  }) async {
    final body = <String, dynamic>{
      'firstName': firstName.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
    };
    if (lastName != null && lastName.trim().isNotEmpty) {
      body['lastName'] = lastName.trim();
    }

    final responseData = await _client.post(
      ApiConstants.register,
      body: body,
      withAuth: false,
    );

    final authResponse = AuthResponse.fromJson(responseData);
    await _persistSession(authResponse);
    return authResponse;
  }

  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.logout, withAuth: true);
    } catch (_) {
      // Even if network fails, always clear local credentials
    } finally {
      await StorageService.clearAuth();
    }
  }

  UserModel? getLocalUser() {
    final data = StorageService.getUserData();
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  Future<void> _persistSession(AuthResponse auth) async {
    await StorageService.setAuthToken(auth.accessToken);
    await StorageService.setRefreshToken(auth.refreshToken);
    await StorageService.setUserData(auth.user.toJson());
  }
}

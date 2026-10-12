import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../services/storage_service.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final List<dynamic>? errors;

  ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  @override
  String toString() => message;
}

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _buildHeaders({bool withAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth) {
      final token = StorageService.getAuthToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final response = await _client.post(
      url,
      headers: _buildHeaders(withAuth: withAuth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool withAuth = true,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final response = await _client.get(
      url,
      headers: _buildHeaders(withAuth: withAuth),
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> data = {};
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {
        data = {'message': response.body};
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final message = data['message'] as String? ?? 'An unexpected error occurred';
    final errors = data['errors'] as List<dynamic>?;

    throw ApiException(
      statusCode: response.statusCode,
      message: message,
      errors: errors,
    );
  }

  void close() {
    _client.close();
  }
}

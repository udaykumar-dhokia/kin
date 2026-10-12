class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String? lastName;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    this.lastName,
  });

  String get fullName {
    if (lastName == null || lastName!.trim().isEmpty) {
      return firstName;
    }
    return '$firstName $lastName';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}

class AuthResponse {
  final String message;
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  const AuthResponse({
    required this.message,
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] as String? ?? '',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }
}

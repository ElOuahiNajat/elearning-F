class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class AuthResponse {
  final String accessToken;

  AuthResponse({required this.accessToken});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
    );
  }
}

// lib/core/services/auth_service.dart

import '../constants/app_constants.dart';
import 'api_service.dart';
import 'session_service.dart';

class AuthService {
  AuthService._();

  // ✅ Backend requires: email, password, role
  static Future<void> login({
    required String email,
    required String password,
    required String role, // "STUDENT" or "ADMIN"
  }) async {
    final res = await ApiService.post(
      AppConstants.login,
      body: {
        "email": email.trim(),
        "password": password,
        "role": role, // send exactly as selected
      },
      auth: false,
    );

    final token = (res["token"] ?? res["accessToken"] ?? "").toString();

    await SessionService.saveSession(
      token: token.isEmpty ? "NO_TOKEN" : token,
      role: role,
      email: email.trim(),
    );
  }

  static Future<void> logout() async {
    await SessionService.clear();
  }
}

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
    final payload = {
      "email": email.trim(),
      "password": password,
      "role": role, // send exactly as selected
    };
    Map<String, dynamic> res;
    try {
      res = await ApiService.post(
        AppConstants.login,
        body: payload,
        auth: false,
      );
    } catch (e) {
      final msg = e.toString().toLowerCase();
      final shouldRetryLegacy = msg.contains("not found") ||
          msg.contains("cannot post") ||
          msg.contains("(404)");
      if (!shouldRetryLegacy) rethrow;
      res = await ApiService.post(
        AppConstants.legacyLogin,
        body: payload,
        auth: false,
      );
    }

    final token = (res["token"] ?? res["accessToken"] ?? "").toString();

    if (token.isEmpty) {
      throw Exception("Login failed: token not returned by server.");
    }

    await SessionService.saveSession(
      token: token,
      role: role,
      email: email.trim(),
    );
  }

  static Future<void> logout() async {
    await SessionService.clear();
  }
}

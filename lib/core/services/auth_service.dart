// lib/core/services/auth_service.dart

import 'package:google_sign_in/google_sign_in.dart';

import '../constants/app_constants.dart';
import 'api_service.dart';
import 'session_service.dart';

class AuthService {
  AuthService._();
  static const String _googleWebClientId =
      String.fromEnvironment(
        "GOOGLE_WEB_CLIENT_ID",
        defaultValue: "623885943651-084aveak7dhv40u32rbre1bqotjncngf.apps.googleusercontent.com",
      );

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

  static Future<void> signInWithGoogle({
    required String role,
  }) async {
    if (_googleWebClientId.isEmpty) {
      throw Exception("Google Sign-In is not configured. Add GOOGLE_WEB_CLIENT_ID.");
    }

    final signIn = GoogleSignIn(
      scopes: const ['email'],
      serverClientId: _googleWebClientId,
    );

    await signIn.signOut();
    final account = await signIn.signIn();
    if (account == null) {
      throw Exception("Google sign-in cancelled.");
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception("Google idToken was not returned.");
    }

    final res = await ApiService.post(
      AppConstants.googleLogin,
      body: {
        "idToken": idToken,
        "role": role,
      },
      auth: false,
    );

    final token = (res["token"] ?? "").toString();
    if (token.isEmpty) {
      throw Exception("Google login failed: token not returned by server.");
    }

    final email = (res["user"] is Map<String, dynamic>)
        ? (res["user"]["email"] ?? account.email).toString()
        : account.email;

    await SessionService.saveSession(
      token: token,
      role: role,
      email: email,
    );
  }

  static Future<void> logout() async {
    await SessionService.clear();
  }
}

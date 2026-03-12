// lib/core/services/auth_service.dart

import 'package:flutter/services.dart';
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
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email'],
    serverClientId: _googleWebClientId,
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

    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw Exception("Google sign-in cancelled.");
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          "Google idToken was not returned. Check OAuth web client configuration.",
        );
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
    } on PlatformException catch (e) {
      throw Exception(_googlePlatformError(e));
    }
  }

  static Future<void> logout() async {
    await SessionService.clear();
  }

  static String _googlePlatformError(PlatformException e) {
    final message = '${e.code} ${e.message ?? ""}'.toLowerCase();
    if (message.contains('apiexception: 10') || message.contains('api10')) {
      return 'Google Sign-In Android OAuth is misconfigured. Verify Android client package and SHA-1 in Google Cloud.';
    }
    if (message.contains('apiexception: 7') || message.contains('api7')) {
      return 'Google Sign-In failed due to network or missing internet permission. Rebuild the app and verify Google Play Services/network.';
    }
    if (message.contains('network')) {
      return 'Google Sign-In network error. Check internet access and Google Play Services.';
    }
    if (message.contains('sign_in_failed')) {
      return 'Google Sign-In failed. Verify web client ID, Android OAuth client, and Play Services on the device.';
    }
    return 'Google Sign-In failed: ${e.message ?? e.code}';
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _kToken = "token";
  static const _kRole = "role";
  static const _kEmail = "email";

  static Future<void> saveSession({
    required String token,
    required String role,
    required String email,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kToken, token);
    await sp.setString(_kRole, role);
    await sp.setString(_kEmail, email);
  }

  static Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kToken);
  }

  static Future<String?> getRole() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kRole);
  }

  static Future<String?> getEmail() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kEmail);
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kToken);
    await sp.remove(_kRole);
    await sp.remove(_kEmail);
  }
}

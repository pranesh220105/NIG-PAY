import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _kToken = "token";
  static const _kRole = "role";
  static const _kEmail = "email";
  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  static Future<void> saveSession({
    required String token,
    required String role,
    required String email,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await _secure.write(key: _kToken, value: token);
    await sp.setString(_kRole, role);
    await sp.setString(_kEmail, email);
  }

  static Future<String?> getToken() async {
    return _secure.read(key: _kToken);
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
    await _secure.delete(key: _kToken);
    await sp.remove(_kRole);
    await sp.remove(_kEmail);
  }

  static Future<bool> isTokenExpired() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return true;
    try {
      return JwtDecoder.isExpired(token);
    } catch (_) {
      return true;
    }
  }
}

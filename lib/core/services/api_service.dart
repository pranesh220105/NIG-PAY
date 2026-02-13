import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import 'session_service.dart';

class ApiService {
  ApiService._();

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final headers = await _headers(auth: auth);
    final res = await http.post(
      AppConstants.uri(path),
      headers: headers,
      body: jsonEncode(body ?? {}),
    );

    return _handle(res);
  }

  static Future<Map<String, dynamic>> get(
    String path, {
    bool auth = false,
  }) async {
    final headers = await _headers(auth: auth);
    final res = await http.get(
      AppConstants.uri(path),
      headers: headers,
    );
    return _handle(res);
  }

  static Future<Map<String, String>> _headers({required bool auth}) async {
    final h = <String, String>{
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
    if (auth) {
      final token = await SessionService.getToken();
      if (token != null && token.isNotEmpty) {
        h["Authorization"] = "Bearer $token";
      }
    }
    return h;
  }

  static Map<String, dynamic> _handle(http.Response res) {
    final code = res.statusCode;
    final text = res.body;

    Map<String, dynamic> decoded;
    try {
      decoded = text.isEmpty ? {} : (jsonDecode(text) as Map<String, dynamic>);
    } catch (_) {
      decoded = {"message": text};
    }

    if (code >= 200 && code < 300) return decoded;

    final msg = decoded["message"]?.toString() ??
        decoded["error"]?.toString() ??
        "Request failed ($code)";
    throw Exception(msg);
  }
}

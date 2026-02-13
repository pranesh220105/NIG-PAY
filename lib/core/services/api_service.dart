import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import 'session_service.dart';

class ApiService {
  ApiService._();
  static Future<void> Function()? onUnauthorized;
  static bool _isHandlingUnauthorized = false;
  static const Duration _timeout = Duration(seconds: 18);
  static const int _maxRetries = 2;

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    return _requestWithRetry(() async {
      final headers = await _headers(auth: auth);
      final res = await http
          .post(
            AppConstants.uri(path),
            headers: headers,
            body: jsonEncode(body ?? {}),
          )
          .timeout(_timeout);
      return _handle(res);
    });
  }

  static Future<Map<String, dynamic>> get(
    String path, {
    bool auth = false,
  }) async {
    return _requestWithRetry(() async {
      final headers = await _headers(auth: auth);
      final res = await http
          .get(
            AppConstants.uri(path),
            headers: headers,
          )
          .timeout(_timeout);
      return _handle(res);
    });
  }

  static Future<Map<String, String>> _headers({required bool auth}) async {
    final h = <String, String>{
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
    if (auth) {
      final expired = await SessionService.isTokenExpired();
      if (expired) {
        await _notifyUnauthorized();
        throw Exception("Session expired. Please login again.");
      }

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
    if (code == 401) {
      _notifyUnauthorized();
    }

    final msg = decoded["message"]?.toString() ??
        decoded["error"]?.toString() ??
        "Request failed ($code)";
    throw Exception(msg);
  }

  static Future<Map<String, dynamic>> _requestWithRetry(
    Future<Map<String, dynamic>> Function() fn,
  ) async {
    Object? lastError;
    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        return await fn();
      } on SocketException catch (e) {
        lastError = e;
      } on HttpException catch (e) {
        lastError = e;
      } on TimeoutException catch (e) {
        lastError = e;
      } on FormatException catch (e) {
        lastError = e;
      } on Exception catch (e) {
        final msg = e.toString();
        if (msg.contains("(401)") || msg.toLowerCase().contains("token")) rethrow;
        lastError = e;
      }
      if (attempt < _maxRetries) {
        await Future<void>.delayed(Duration(milliseconds: 350 * (attempt + 1)));
      }
    }
    throw Exception(_friendlyError(lastError));
  }

  static String _friendlyError(Object? error) {
    if (error == null) return "Request failed";
    if (error is SocketException) return "No internet connection. Please try again.";
    if (error is HttpException) return "Network error. Please try again.";
    if (error is TimeoutException) return "Request timed out. Please retry.";
    if (error is FormatException) return "Unexpected server response.";
    return error.toString().replaceFirst("Exception: ", "");
  }

  static Future<void> _notifyUnauthorized() async {
    if (_isHandlingUnauthorized) return;
    _isHandlingUnauthorized = true;
    try {
      final cb = onUnauthorized;
      if (cb != null) await cb();
    } finally {
      _isHandlingUnauthorized = false;
    }
  }
}

// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // ✅ NGROK BASE URL
  static const String baseUrl =
      "https://wayne-maintainable-tennille.ngrok-free.dev";

  static Uri uri(String path) => Uri.parse("$baseUrl$path");

  // ✅ AUTH (your backend log shows /auth/login)
  static const String login = "/auth/login";
  static const String register = "/auth/register";

  // ✅ STUDENT
  static const String studentDashboard = "/api/student/dashboard";

  // ✅ ADMIN (added because your admin_add_fee_screen expects addFee)
  // If your backend route differs, change only this string.
  static const String addFee = "/api/admin/fee/add";
}

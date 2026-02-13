import 'dart:io';

class AppConstants {
  AppConstants._();

  // ✅ Laptop IP on college WiFi + backend port
  static const String collegeWifiBaseUrl = "http://10.130.21.28:5000";

  // Optional (only if you use emulator later)
  static const String androidEmulatorBaseUrl = "http://10.0.2.2:5000";
  static const String iosSimulatorBaseUrl = "http://localhost:5000";

  static String get baseUrl {
    if (Platform.isAndroid) return collegeWifiBaseUrl; // real phone
    if (Platform.isIOS) return iosSimulatorBaseUrl;
    return collegeWifiBaseUrl;
  }

  static Uri uri(String path) => Uri.parse("$baseUrl$path");

  // ============== API PATHS (EDIT IF YOUR ROUTES DIFFER) ==============
  static const String api = "/api";

  static const String login = "$api/auth/login";
  static const String register = "$api/auth/register";

  static const String studentDashboard = "$api/student/dashboard";
  static const String studentPayments = "$api/student/payments";
  static const String makePayment = "$api/student/pay";

  static const String adminDashboard = "$api/admin/dashboard";
  static const String addFee = "$api/admin/fee/add";
}

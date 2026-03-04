class AppConstants {
  AppConstants._();

  static const String _defaultDevBaseUrl = "https://wayne-maintainable-tennille.ngrok-free.dev";
  static const String _defaultProdBaseUrl = "https://college-fee-wallet-api.onrender.com";
  static const String _env = String.fromEnvironment("APP_ENV", defaultValue: "prod");
  static const String _devBaseUrl = String.fromEnvironment("DEV_BASE_URL", defaultValue: _defaultDevBaseUrl);
  static const String _prodBaseUrl = String.fromEnvironment("PROD_BASE_URL", defaultValue: _defaultProdBaseUrl);

  static String get baseUrl => _env == "prod" ? _prodBaseUrl : _devBaseUrl;

  static Uri uri(String path) => Uri.parse("$baseUrl$path");

  static const String login = "/api/auth/login";
  static const String googleLogin = "/api/auth/google";
  static const String register = "/api/auth/register";
  static const String legacyLogin = "/auth/login";
  static const String legacyRegister = "/auth/register";

  static const String studentDashboard = "/api/student/dashboard";
  static const String studentPayments = "/api/student/payments";
  static const String makePayment = "/api/student/pay";

  static const String addFee = "/api/admin/fee/add";
  static const String adminListStudents = "/api/admin/students";
  static const String adminCreateStudent = "/api/admin/students";
  static const String adminSetSemesterFee = "/api/admin/fee/semester";
  static const String adminBulkAssignFee = "/api/admin/fee/bulk";
  static const String adminMarkFee = "/api/admin/fee/mark";
}

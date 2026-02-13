import '../constants/app_constants.dart';
import '../models/dashboard_models.dart';
import '../models/payment_model.dart';
import '../models/receipt_model.dart';
import '../services/api_service.dart';

class StudentRepository {
  Future<StudentDashboard> fetchDashboard() async {
    final res = await ApiService.get(AppConstants.studentDashboard, auth: true);
    final map = (res["data"] is Map<String, dynamic>) ? res["data"] as Map<String, dynamic> : res;
    return StudentDashboard.fromJson(map);
  }

  Future<List<PaymentModel>> fetchPayments() async {
    final res = await ApiService.get(AppConstants.studentPayments, auth: true);
    final list = (res["payments"] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(PaymentModel.fromJson)
        .toList();
    return list;
  }

  Future<List<ReceiptModel>> fetchReceipts() async {
    final res = await ApiService.get(AppConstants.studentPayments, auth: true);
    return (res["payments"] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ReceiptModel.fromPaymentJson)
        .toList();
  }

  Future<void> makePayment(int amount) async {
    await ApiService.post(
      AppConstants.makePayment,
      auth: true,
      body: {"amount": amount},
    );
  }
}

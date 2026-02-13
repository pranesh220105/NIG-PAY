import 'package:flutter/material.dart';

import '../../../core/models/dashboard_models.dart';
import '../../../core/models/payment_model.dart';
import '../../../core/models/receipt_model.dart';
import '../../../core/repositories/student_repository.dart';
import '../../../core/state/view_state.dart';

class StudentVm extends ChangeNotifier {
  StudentVm(this._repo);

  final StudentRepository _repo;

  ViewState dashboardState = ViewState.idle;
  ViewState paymentsState = ViewState.idle;
  ViewState payActionState = ViewState.idle;
  ViewState receiptsState = ViewState.idle;

  StudentDashboard dashboard = const StudentDashboard(
    totalFee: 0,
    paidFee: 0,
    pendingFee: 0,
    totalFineDue: 0,
    semesterBreakdown: [],
  );
  List<PaymentModel> payments = const [];
  List<ReceiptModel> receipts = const [];

  String? dashboardError;
  String? paymentsError;
  String? payError;
  String? receiptsError;

  Future<void> loadDashboard() async {
    dashboardState = ViewState.loading;
    dashboardError = null;
    notifyListeners();
    try {
      dashboard = await _repo.fetchDashboard();
      dashboardState = ViewState.success;
    } catch (e) {
      dashboardState = ViewState.error;
      dashboardError = e.toString().replaceFirst("Exception: ", "");
    }
    notifyListeners();
  }

  Future<void> loadReceipts() async {
    receiptsState = ViewState.loading;
    receiptsError = null;
    notifyListeners();
    try {
      receipts = await _repo.fetchReceipts();
      receiptsState = ViewState.success;
    } catch (e) {
      receiptsState = ViewState.error;
      receiptsError = e.toString().replaceFirst("Exception: ", "");
    }
    notifyListeners();
  }

  Future<void> loadPayments() async {
    paymentsState = ViewState.loading;
    paymentsError = null;
    notifyListeners();
    try {
      payments = await _repo.fetchPayments();
      paymentsState = ViewState.success;
    } catch (e) {
      paymentsState = ViewState.error;
      paymentsError = e.toString().replaceFirst("Exception: ", "");
    }
    notifyListeners();
  }

  Future<bool> payNow(int amount) async {
    payActionState = ViewState.loading;
    payError = null;
    notifyListeners();
    try {
      await _repo.makePayment(amount);
      payActionState = ViewState.success;
      await Future.wait([loadDashboard(), loadPayments()]);
      return true;
    } catch (e) {
      payActionState = ViewState.error;
      payError = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    }
  }
}

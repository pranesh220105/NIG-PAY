class ReceiptModel {
  final String receiptId;
  final String title;
  final int amount;
  final DateTime paidAt;
  final String status;

  const ReceiptModel({
    required this.receiptId,
    required this.title,
    required this.amount,
    required this.paidAt,
    required this.status,
  });

  factory ReceiptModel.fromPaymentJson(Map<String, dynamic> json) {
    final id = (json["id"] ?? "").toString();
    final amount = int.tryParse((json["amount"] ?? 0).toString()) ?? 0;
    final time = DateTime.tryParse((json["updatedAt"] ?? "").toString()) ?? DateTime.now();
    return ReceiptModel(
      receiptId: "RCPT-$id",
      title: (json["title"] ?? "Payment").toString(),
      amount: amount,
      paidAt: time,
      status: (json["status"] ?? "PAID").toString(),
    );
  }
}

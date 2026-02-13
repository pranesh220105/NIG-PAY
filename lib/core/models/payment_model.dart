class PaymentModel {
  final int id;
  final String title;
  final int amount;
  final String status;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.status,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) => int.tryParse(value.toString()) ?? 0;
    DateTime parseDate(dynamic value) =>
        DateTime.tryParse(value?.toString() ?? "") ?? DateTime.now();

    return PaymentModel(
      id: toInt(json["id"]),
      title: (json["title"] ?? "Payment").toString(),
      amount: toInt(json["amount"]),
      status: (json["status"] ?? "PAID").toString(),
      description: json["description"]?.toString(),
      createdAt: parseDate(json["createdAt"]),
      updatedAt: parseDate(json["updatedAt"]),
    );
  }
}

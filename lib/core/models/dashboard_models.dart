class StudentDashboard {
  final int totalFee;
  final int paidFee;
  final int pendingFee;

  const StudentDashboard({
    required this.totalFee,
    required this.paidFee,
    required this.pendingFee,
  });

  factory StudentDashboard.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => int.tryParse(v.toString()) ?? 0;

    // Support multiple keys just in case
    final total = toInt(json["totalFee"] ?? json["total"] ?? 0);
    final paid = toInt(json["paidFee"] ?? json["paid"] ?? 0);
    final pending = toInt(json["pendingFee"] ?? json["pending"] ?? (total - paid));

    return StudentDashboard(totalFee: total, paidFee: paid, pendingFee: pending);
  }
}

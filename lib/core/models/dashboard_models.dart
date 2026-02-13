class SemesterDue {
  final String semester;
  final int total;
  final int paid;
  final int pending;
  final int fineDue;

  const SemesterDue({
    required this.semester,
    required this.total,
    required this.paid,
    required this.pending,
    required this.fineDue,
  });

  factory SemesterDue.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => int.tryParse(v.toString()) ?? 0;
    return SemesterDue(
      semester: (json["semester"] ?? "General").toString(),
      total: toInt(json["total"]),
      paid: toInt(json["paid"]),
      pending: toInt(json["pending"]),
      fineDue: toInt(json["fineDue"]),
    );
  }
}

class StudentDashboard {
  final int totalFee;
  final int paidFee;
  final int pendingFee;
  final int totalFineDue;
  final List<SemesterDue> semesterBreakdown;

  const StudentDashboard({
    required this.totalFee,
    required this.paidFee,
    required this.pendingFee,
    required this.totalFineDue,
    required this.semesterBreakdown,
  });

  factory StudentDashboard.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => int.tryParse(v.toString()) ?? 0;
    final total = toInt(json["totalFee"] ?? json["total"] ?? 0);
    final paid = toInt(json["paidFee"] ?? json["paid"] ?? 0);
    final pending = toInt(json["pendingFee"] ?? json["pending"] ?? (total - paid));
    final fine = toInt(json["totalFineDue"] ?? 0);

    final rawSemesters = (json["semesterBreakdown"] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(SemesterDue.fromJson)
        .toList();

    return StudentDashboard(
      totalFee: total,
      paidFee: paid,
      pendingFee: pending,
      totalFineDue: fine,
      semesterBreakdown: rawSemesters,
    );
  }
}

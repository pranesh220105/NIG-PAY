import 'package:flutter/material.dart';

class StudentHistoryScreen extends StatelessWidget {
  const StudentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text("Payment History"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _historyCard(
            title: "Semester Fee",
            date: "12 Feb 2026",
            amount: "₹ 15000",
            status: "SUCCESS",
          ),
          const SizedBox(height: 12),
          _historyCard(
            title: "Library Fee",
            date: "01 Jan 2026",
            amount: "₹ 2000",
            status: "SUCCESS",
          ),
          const SizedBox(height: 12),
          _historyCard(
            title: "Exam Fee",
            date: "15 Dec 2025",
            amount: "₹ 1000",
            status: "PENDING",
          ),
        ],
      ),
    );
  }

  Widget _historyCard({
    required String title,
    required String date,
    required String amount,
    required String status,
  }) {
    final bool success = status == "SUCCESS";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: success
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFFEDD5),
            ),
            child: Icon(
              success ? Icons.check_circle_rounded : Icons.timelapse_rounded,
              color: success ? const Color(0xFF15803D) : const Color(0xFF9A3412),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.60)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: success ? const Color(0xFF15803D) : const Color(0xFF9A3412),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

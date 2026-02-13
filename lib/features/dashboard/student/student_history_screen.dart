import 'package:flutter/material.dart';

class StudentHistoryScreen extends StatelessWidget {
  const StudentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Payment History", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: const [
                  _HistoryCard(title: "Semester 5 Fee", amount: 25000, date: "2026-01-20", status: "PAID"),
                  _HistoryCard(title: "Lab Fee", amount: 1500, date: "2025-12-14", status: "PAID"),
                  _HistoryCard(title: "Library Fine", amount: 200, date: "2025-11-08", status: "PAID"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final int amount;
  final String date;
  final String status;

  const _HistoryCard({
    required this.title,
    required this.amount,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      child: ListTile(
        leading: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.green.withOpacity(0.12),
          ),
          child: const Icon(Icons.receipt_long_rounded, color: Colors.green),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text("Date: $date"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("₹ $amount", style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AdminStudentsScreen extends StatelessWidget {
  const AdminStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Students", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: const [
                  _StudentRow(name: "Student A", email: "student1@test.com", pending: 12000),
                  _StudentRow(name: "Student B", email: "student2@test.com", pending: 0),
                  _StudentRow(name: "Student C", email: "student3@test.com", pending: 5600),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final String name;
  final String email;
  final int pending;

  const _StudentRow({required this.name, required this.email, required this.pending});

  @override
  Widget build(BuildContext context) {
    final pendingColor = pending == 0 ? Colors.green : Colors.orange;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        leading: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: pendingColor.withValues(alpha: 0.12),
          ),
          child: Icon(Icons.person_rounded, color: pendingColor),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(email),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("Pending", style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.6))),
            const SizedBox(height: 4),
            Text(
              "₹ $pending",
              style: TextStyle(fontWeight: FontWeight.w900, color: pendingColor),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';

class AdminControlsScreen extends StatefulWidget {
  const AdminControlsScreen({super.key});

  @override
  State<AdminControlsScreen> createState() => _AdminControlsScreenState();
}

class _AdminControlsScreenState extends State<AdminControlsScreen> {
  final _studentEmail = TextEditingController();
  final _studentPassword = TextEditingController(text: "123456");
  final _feeStudentEmail = TextEditingController();
  final _semester = TextEditingController();
  final _amount = TextEditingController();
  final _dueDate = TextEditingController();
  final _fineAmount = TextEditingController();
  final _feeId = TextEditingController();
  final _paidAmount = TextEditingController();

  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    _studentEmail.dispose();
    _studentPassword.dispose();
    _feeStudentEmail.dispose();
    _semester.dispose();
    _amount.dispose();
    _dueDate.dispose();
    _fineAmount.dispose();
    _feeId.dispose();
    _paidAmount.dispose();
    super.dispose();
  }

  Future<void> _call(Future<void> Function() run) async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await run();
      if (!mounted) return;
      setState(() => _message = "Success");
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Controls")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_message != null) ...[
            _InfoCard(message: _message!),
            const SizedBox(height: 12),
          ],
          _SectionCard(
            title: "Create Student",
            children: [
              TextField(controller: _studentEmail, decoration: const InputDecoration(labelText: "Student email")),
              const SizedBox(height: 10),
              TextField(controller: _studentPassword, decoration: const InputDecoration(labelText: "Temporary password")),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () => _call(() async {
                          await ApiService.post(
                            AppConstants.adminCreateStudent,
                            auth: true,
                            body: {
                              "email": _studentEmail.text.trim(),
                              "password": _studentPassword.text.trim(),
                            },
                          );
                        }),
                child: const Text("Create Student"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: "Set Semester Fee",
            children: [
              TextField(controller: _feeStudentEmail, decoration: const InputDecoration(labelText: "Student email")),
              const SizedBox(height: 10),
              TextField(controller: _semester, decoration: const InputDecoration(labelText: "Semester (e.g. Sem 5)")),
              const SizedBox(height: 10),
              TextField(controller: _amount, decoration: const InputDecoration(labelText: "Amount"), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              TextField(controller: _dueDate, decoration: const InputDecoration(labelText: "Due date YYYY-MM-DD")),
              const SizedBox(height: 10),
              TextField(controller: _fineAmount, decoration: const InputDecoration(labelText: "Fine amount"), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () => _call(() async {
                          await ApiService.post(
                            AppConstants.adminSetSemesterFee,
                            auth: true,
                            body: {
                              "studentEmail": _feeStudentEmail.text.trim(),
                              "semester": _semester.text.trim(),
                              "amount": int.tryParse(_amount.text.trim()) ?? 0,
                              "dueDate": _dueDate.text.trim().isEmpty ? null : _dueDate.text.trim(),
                              "fineAmount": int.tryParse(_fineAmount.text.trim()) ?? 0,
                            },
                          );
                        }),
                child: const Text("Set Semester Fee"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: "Mark Paid / Partial",
            children: [
              TextField(controller: _feeId, decoration: const InputDecoration(labelText: "Fee ID"), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              TextField(controller: _paidAmount, decoration: const InputDecoration(labelText: "Amount paid"), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () => _call(() async {
                          await ApiService.post(
                            AppConstants.adminMarkFee,
                            auth: true,
                            body: {
                              "feeId": int.tryParse(_feeId.text.trim()) ?? 0,
                              "amountPaid": int.tryParse(_paidAmount.text.trim()) ?? 0,
                            },
                          );
                        }),
                child: const Text("Submit Payment Update"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String message;

  const _InfoCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final error = message.toLowerCase().contains("failed") ||
        message.toLowerCase().contains("error") ||
        message.toLowerCase().contains("invalid");
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: error ? Colors.red.withAlpha(20) : Colors.green.withAlpha(20),
        border: Border.all(color: error ? Colors.red.withAlpha(80) : Colors.green.withAlpha(80)),
      ),
      child: Text(message),
    );
  }
}

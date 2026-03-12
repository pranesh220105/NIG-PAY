import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  final _studentEmail = TextEditingController();
  final _studentPassword = TextEditingController(text: "123456");

  bool _loading = false;
  bool _studentsLoading = false;
  String? _message;
  List<_StudentItem> _students = const [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _studentEmail.dispose();
    _studentPassword.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _studentsLoading = true;
      _message = null;
    });
    try {
      final res = await ApiService.get(AppConstants.adminListStudents, auth: true);
      final raw = (res["students"] as List<dynamic>? ?? const []);
      final students = raw
          .whereType<Map<String, dynamic>>()
          .map(_StudentItem.fromJson)
          .toList()
        ..sort((a, b) => a.email.compareTo(b.email));
      if (!mounted) return;
      setState(() => _students = students);
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _studentsLoading = false);
    }
  }

  Future<void> _createStudent() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final res = await ApiService.post(
        AppConstants.adminCreateStudent,
        auth: true,
        body: {
          "email": _studentEmail.text.trim(),
          "password": _studentPassword.text.trim(),
        },
      );
      _studentEmail.clear();
      _studentPassword.text = "123456";
      await _loadStudents();
      if (!mounted) return;
      setState(() => _message = res["message"]?.toString() ?? "Student created");
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteStudent(_StudentItem student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete student"),
        content: Text("Delete ${student.email} and all linked fee records?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final res = await ApiService.delete(
        "${AppConstants.adminDeleteStudent}/${student.id}",
        auth: true,
      );
      await _loadStudents();
      if (!mounted) return;
      setState(() => _message = res["message"]?.toString() ?? "Student deleted");
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetStudentLedger(_StudentItem student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset current totals"),
        content: Text(
          "Archive all active fee rows for ${student.email}? Current dashboard totals will become zero, but transaction history stays available.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Reset"),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final res = await ApiService.post(
        "${AppConstants.adminResetStudentLedger}/${student.id}/reset-ledger",
        auth: true,
        body: const {},
      );
      await _loadStudents();
      if (!mounted) return;
      setState(() => _message = res["message"]?.toString() ?? "Student totals reset");
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
      appBar: AppBar(title: const Text("Students")),
      body: RefreshIndicator(
        onRefresh: _loadStudents,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_message != null) ...[
              _InfoCard(message: _message!),
              const SizedBox(height: 12),
            ],
            _SectionCard(
              title: "Create Student",
              subtitle: "Add a student account with a temporary password.",
              children: [
                TextField(
                  controller: _studentEmail,
                  decoration: const InputDecoration(labelText: "Student email"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _studentPassword,
                  decoration: const InputDecoration(labelText: "Temporary password"),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loading ? null : _createStudent,
                  child: const Text("Create Student"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: "All Students",
              subtitle: "View, reset current totals, and delete student accounts.",
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _studentsLoading ? "Loading students..." : "${_students.length} students loaded",
                        style: TextStyle(fontSize: 12, color: Colors.black.withAlpha(150)),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _studentsLoading ? null : _loadStudents,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text("Refresh"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_studentsLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_students.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text("No students found."),
                  )
                else
                  ..._students.map(
                    (student) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(student.email, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(
                        "Fees created: ${student.feeCount}  |  Active pending: Rs ${student.activePendingAmount}",
                      ),
                      trailing: Wrap(
                        spacing: 2,
                        children: [
                          IconButton(
                            tooltip: "Reset current totals",
                            onPressed: _loading ? null : () => _resetStudentLedger(student),
                            icon: const Icon(Icons.restart_alt_rounded),
                            color: Colors.orange,
                          ),
                          IconButton(
                            tooltip: "Delete student",
                            onPressed: _loading ? null : () => _deleteStudent(student),
                            icon: const Icon(Icons.delete_outline_rounded),
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.black.withAlpha(150))),
            const SizedBox(height: 12),
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
    final lower = message.toLowerCase();
    final error = lower.contains("failed") || lower.contains("error") || lower.contains("invalid");
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: error ? Colors.red.withAlpha(20) : Colors.green.withAlpha(20),
        border: Border.all(color: error ? Colors.red.withAlpha(80) : Colors.green.withAlpha(80)),
      ),
      child: Text(message),
    );
  }
}

class _StudentItem {
  final int id;
  final String email;
  final int feeCount;
  final int activePendingAmount;

  const _StudentItem({
    required this.id,
    required this.email,
    required this.feeCount,
    required this.activePendingAmount,
  });

  factory _StudentItem.fromJson(Map<String, dynamic> json) {
    return _StudentItem(
      id: (json["id"] as num?)?.toInt() ?? 0,
      email: (json["email"] ?? "").toString(),
      feeCount: (json["feeCount"] as num?)?.toInt() ?? 0,
      activePendingAmount: (json["activePendingAmount"] as num?)?.toInt() ?? 0,
    );
  }
}

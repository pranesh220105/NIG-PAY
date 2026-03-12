import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';

class AdminControlsScreen extends StatefulWidget {
  const AdminControlsScreen({super.key});

  @override
  State<AdminControlsScreen> createState() => _AdminControlsScreenState();
}

class _AdminControlsScreenState extends State<AdminControlsScreen> {
  final _semester = TextEditingController();
  final _amount = TextEditingController();
  final _dueDate = TextEditingController();
  final _fineAmount = TextEditingController();
  final _customFeeLabel = TextEditingController();
  final _feeId = TextEditingController();
  final _paidAmount = TextEditingController();

  bool _loading = false;
  bool _studentsLoading = false;
  bool _applyToAll = false;
  String? _message;
  String _feeType = "SEMESTER_FEE";
  List<_StudentItem> _students = const [];
  final Set<int> _selectedStudentIds = <int>{};

  static const _feeOptions = <_FeeOption>[
    _FeeOption(value: "SEMESTER_FEE", label: "Semester Fee", hint: "Main academic semester dues"),
    _FeeOption(value: "PAPER_FEE", label: "Paper Fee", hint: "Exam and paper-related charges"),
    _FeeOption(value: "COURSE_FEE", label: "Course Fee", hint: "Specific subject or lab fee"),
    _FeeOption(value: "BUS_FEE", label: "Bus Fee", hint: "Transport and route charges"),
    _FeeOption(value: "HOSTEL_FEE", label: "Hostel Fee", hint: "Accommodation dues"),
    _FeeOption(value: "LIBRARY_FEE", label: "Library Fee", hint: "Library access and deposits"),
  ];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _semester.dispose();
    _amount.dispose();
    _dueDate.dispose();
    _fineAmount.dispose();
    _customFeeLabel.dispose();
    _feeId.dispose();
    _paidAmount.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _studentsLoading = true);
    try {
      final res = await ApiService.get(AppConstants.adminListStudents, auth: true);
      final raw = (res["students"] as List<dynamic>? ?? const []);
      final students = raw
          .whereType<Map<String, dynamic>>()
          .map(_StudentItem.fromJson)
          .toList()
        ..sort((a, b) => a.email.compareTo(b.email));
      if (!mounted) return;
      setState(() {
        _students = students;
        _selectedStudentIds.removeWhere((id) => !_students.any((student) => student.id == id));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _studentsLoading = false);
    }
  }

  Future<void> _call(Future<String?> Function() run) async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final msg = await run();
      if (!mounted) return;
      setState(() => _message = msg ?? "Success");
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _defaultFeeLabel() {
    final semester = _semester.text.trim();
    final selected = _feeOptions.firstWhere(
      (item) => item.value == _feeType,
      orElse: () => _feeOptions.first,
    );
    if (semester.isEmpty) return selected.label;
    return "$semester ${selected.label}";
  }

  String _selectionLabel() {
    if (_applyToAll) return "All students selected";
    if (_selectedStudentIds.isEmpty) return "No students selected";
    if (_selectedStudentIds.length == 1) {
      final student = _students.firstWhere(
        (item) => item.id == _selectedStudentIds.first,
        orElse: () => const _StudentItem(id: 0, email: "Unknown", feeCount: 0),
      );
      return "Selected: ${student.email}";
    }
    return "${_selectedStudentIds.length} students selected";
  }

  Future<void> _assignFee() async {
    await _call(() async {
      final body = {
        "semester": _semester.text.trim(),
        "feeType": _feeType,
        "feeLabel": _customFeeLabel.text.trim().isEmpty ? null : _customFeeLabel.text.trim(),
        "amount": int.tryParse(_amount.text.trim()) ?? 0,
        "dueDate": _dueDate.text.trim().isEmpty ? null : _dueDate.text.trim(),
        "fineAmount": int.tryParse(_fineAmount.text.trim()) ?? 0,
      };

      if (_applyToAll || _selectedStudentIds.length > 1) {
        final res = await ApiService.post(
          AppConstants.adminBulkAssignFee,
          auth: true,
          body: {
            ...body,
            "applyToAll": _applyToAll,
            "studentIds": _selectedStudentIds.toList(),
          },
        );
        await _loadStudents();
        return res["message"]?.toString() ?? "Fee assigned";
      }

      if (_selectedStudentIds.length == 1) {
        final student = _students.firstWhere((item) => item.id == _selectedStudentIds.first);
        final res = await ApiService.post(
          AppConstants.adminSetSemesterFee,
          auth: true,
          body: {
            ...body,
            "studentEmail": student.email,
          },
        );
        await _loadStudents();
        return res["message"]?.toString() ?? "Fee assigned";
      }

      throw Exception("Select at least one student or enable Apply to all.");
    });
  }

  Future<void> _markFee() async {
    await _call(() async {
      final res = await ApiService.post(
        AppConstants.adminMarkFee,
        auth: true,
        body: {
          "feeId": int.tryParse(_feeId.text.trim()) ?? 0,
          "amountPaid": int.tryParse(_paidAmount.text.trim()) ?? 0,
        },
      );
      return res["message"]?.toString() ?? "Payment updated";
    });
  }

  Future<void> _deleteStudent(_StudentItem student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete student"),
        content: Text(
          "Delete ${student.email} and all linked fee records? This cannot be undone.",
        ),
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

    await _call(() async {
      final res = await ApiService.delete(
        "${AppConstants.adminDeleteStudent}/${student.id}",
        auth: true,
      );
      _selectedStudentIds.remove(student.id);
      await _loadStudents();
      return res["message"]?.toString() ?? "Student deleted";
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = _feeOptions.firstWhere(
      (item) => item.value == _feeType,
      orElse: () => _feeOptions.first,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Controls")),
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
              title: "All Students",
              subtitle: "View students, select specific students, or apply fees to all.",
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
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Apply fee to all students"),
                  subtitle: const Text("Ignore individual selection and assign to every student"),
                  value: _applyToAll,
                  onChanged: _loading
                      ? null
                      : (v) => setState(() {
                            _applyToAll = v;
                          }),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).colorScheme.primary.withAlpha(8),
                  ),
                  child: Text(
                    _selectionLabel(),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 10),
                if (_studentsLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ))
                else if (_students.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text("No students found."),
                  )
                else
                  ..._students.map((student) {
                    final selected = _selectedStudentIds.contains(student.id);
                    return Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            value: _applyToAll ? true : selected,
                            onChanged: _applyToAll || _loading
                                ? null
                                : (value) {
                                    setState(() {
                                      if (value ?? false) {
                                        _selectedStudentIds.add(student.id);
                                      } else {
                                        _selectedStudentIds.remove(student.id);
                                      }
                                    });
                                  },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            title: Text(student.email, style: const TextStyle(fontWeight: FontWeight.w800)),
                            subtitle: Text("Fees created: ${student.feeCount}"),
                          ),
                        ),
                        IconButton(
                          tooltip: "Delete student",
                          onPressed: _loading ? null : () => _deleteStudent(student),
                          icon: const Icon(Icons.delete_outline_rounded),
                          color: Colors.red,
                        ),
                      ],
                    );
                  }),
              ],
            ),
            _SectionCard(
              title: "Assign Fee",
              subtitle: "Add semester, paper, course, bus, hostel, or library fee to selected students or all.",
              children: [
                TextField(
                  controller: _semester,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: "Semester / term (e.g. Sem 5)"),
                ),
                const SizedBox(height: 12),
                const Text("Fee Type", style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _feeOptions.map((option) {
                    return ChoiceChip(
                      label: Text(option.label),
                      selected: _feeType == option.value,
                      onSelected: _loading
                          ? null
                          : (_) => setState(() {
                                _feeType = option.value;
                              }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).colorScheme.primary.withAlpha(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedOption.hint,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _customFeeLabel,
                  decoration: InputDecoration(
                    labelText: "Custom fee title (optional)",
                    hintText: _defaultFeeLabel(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _amount,
                  decoration: const InputDecoration(labelText: "Amount"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _dueDate,
                  decoration: const InputDecoration(labelText: "Due date YYYY-MM-DD"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _fineAmount,
                  decoration: const InputDecoration(labelText: "Fine amount"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loading ? null : _assignFee,
                  child: Text(_applyToAll ? "Assign Fee To All Students" : "Assign Fee"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: "Mark Paid / Partial",
              subtitle: "Update a fee row after offline payment or admin verification.",
              children: [
                TextField(
                  controller: _feeId,
                  decoration: const InputDecoration(labelText: "Fee ID"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _paidAmount,
                  decoration: const InputDecoration(labelText: "Amount paid"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loading ? null : _markFee,
                  child: const Text("Submit Payment Update"),
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

class _FeeOption {
  final String value;
  final String label;
  final String hint;

  const _FeeOption({
    required this.value,
    required this.label,
    required this.hint,
  });
}

class _StudentItem {
  final int id;
  final String email;
  final int feeCount;

  const _StudentItem({
    required this.id,
    required this.email,
    required this.feeCount,
  });

  factory _StudentItem.fromJson(Map<String, dynamic> json) {
    return _StudentItem(
      id: (json["id"] as num?)?.toInt() ?? 0,
      email: (json["email"] ?? "").toString(),
      feeCount: (json["feeCount"] as num?)?.toInt() ?? 0,
    );
  }
}

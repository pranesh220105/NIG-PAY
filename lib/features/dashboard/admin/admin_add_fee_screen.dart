// lib/features/dashboard/admin/admin_add_fee_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';

class AdminAddFeeScreen extends StatefulWidget {
  const AdminAddFeeScreen({super.key});

  @override
  State<AdminAddFeeScreen> createState() => _AdminAddFeeScreenState();
}

class _AdminAddFeeScreenState extends State<AdminAddFeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _amount = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    _email.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => loading = true);
    try {
      await ApiService.post(
        AppConstants.addFee,
        auth: true,
        body: {
          "studentEmail": _email.text.trim(),
          "amount": int.parse(_amount.text.trim()),
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fee added successfully ✅")),
      );
      _email.clear();
      _amount.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Add Fee")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.white,
                border: Border.all(color: _op(Colors.black, 0.06)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: _op(cs.primary, 0.12),
                          ),
                          child: Icon(Icons.add_card_rounded, color: cs.primary),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Add Fee to Student",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                              SizedBox(height: 2),
                              Text("Enter student email and amount",
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Student Email",
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: (v) {
                        final s = (v ?? "").trim();
                        if (s.isEmpty) return "Enter student email";
                        if (!s.contains("@")) return "Enter valid email";
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _amount,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Amount",
                        prefixIcon: Icon(Icons.currency_rupee_rounded),
                      ),
                      validator: (v) {
                        final s = (v ?? "").trim();
                        final n = int.tryParse(s);
                        if (n == null || n <= 0) return "Enter valid amount";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : _submit,
                        icon: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: const Text("Submit"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ avoid deprecated withOpacity()
  Color _op(Color c, double opacity) => c.withAlpha((opacity * 255).round());
}

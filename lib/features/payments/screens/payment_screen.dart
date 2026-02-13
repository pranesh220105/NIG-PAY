import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/view_state.dart';
import '../../dashboard/viewmodels/student_vm.dart';

class PaymentScreen extends StatefulWidget {
  final int pendingAmount;
  const PaymentScreen({super.key, required this.pendingAmount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  String _method = "UPI";
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pay(StudentVm vm) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _error = null);
    final ok = await vm.payNow(int.parse(_amount.text.trim()));
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
      return;
    }
    setState(() => _error = vm.payError ?? "Payment failed");
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentVm>();
    final loading = vm.payActionState == ViewState.loading;
    final pending = widget.pendingAmount;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Pay Fee")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(colors: [cs.primary.withAlpha(35), cs.secondary.withAlpha(35)]),
              border: Border.all(color: Colors.black.withAlpha(14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Amount Due", style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text("Rs $pending", style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PresetChip(label: "25%", onTap: () => _amount.text = (pending * 0.25).round().toString()),
                    _PresetChip(label: "50%", onTap: () => _amount.text = (pending * 0.5).round().toString()),
                    _PresetChip(label: "75%", onTap: () => _amount.text = (pending * 0.75).round().toString()),
                    _PresetChip(label: "Full", onTap: () => _amount.text = pending.toString()),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.red.withAlpha(18),
                border: Border.all(color: Colors.red.withAlpha(70)),
              ),
              child: Text(_error!),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Payment Method", style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ["UPI", "Card", "Net Banking"].map((m) {
                        final selected = _method == m;
                        return ChoiceChip(
                          label: Text(m),
                          selected: selected,
                          onSelected: (_) => setState(() => _method = m),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _amount,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Amount",
                        prefixIcon: Icon(Icons.currency_rupee_rounded),
                      ),
                      validator: (v) {
                        final n = int.tryParse((v ?? "").trim());
                        if (n == null || n <= 0) return "Enter valid amount";
                        if (n > pending) return "Cannot exceed pending amount";
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : () => _pay(vm),
                        icon: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.verified_user_rounded),
                        label: Text(loading ? "Processing..." : "Confirm & Pay"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Theme.of(context).cardColor,
          border: Border.all(color: Colors.black.withAlpha(20)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

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
    final payAmount = int.parse(_amount.text.trim());
    final ok = await vm.payNow(payAmount);
    if (!mounted) return;
    if (ok) {
      await showModalBottomSheet<void>(
        context: context,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (_) => _PaymentSuccessSheet(
          amount: payAmount,
          method: _method,
        ),
      );
      if (!mounted) return;
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
    final enteredAmount = int.tryParse(_amount.text.trim()) ?? 0;
    final remainingAfterPay = (pending - enteredAmount).clamp(0, pending);

    return Scaffold(
      appBar: AppBar(title: const Text("Pay Fee")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primary.withAlpha(48),
                  cs.secondary.withAlpha(36),
                  cs.surface,
                ],
              ),
              border: Border.all(color: Colors.black.withAlpha(14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text("Amount Due", style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.black.withAlpha(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_rounded, size: 16, color: cs.primary),
                          const SizedBox(width: 6),
                          const Text(
                            "Secured",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Rs $pending", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                const Text(
                  "Complete dues using an instant wallet-style flow.",
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 14),
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
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _InfoPill(
                        label: "After Payment",
                        value: "Rs $remainingAfterPay",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _InfoPill(
                        label: "Speed",
                        value: _method == "UPI" ? "Instant" : "< 2 min",
                      ),
                    ),
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
              padding: const EdgeInsets.all(16),
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: cs.primary.withAlpha(12),
                        border: Border.all(color: cs.primary.withAlpha(18)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Icon(
                              _method == "UPI"
                                  ? Icons.qr_code_2_rounded
                                  : _method == "Card"
                                      ? Icons.credit_card_rounded
                                      : Icons.account_balance_rounded,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _method == "UPI"
                                      ? "Linked UPI handle"
                                      : _method == "Card"
                                          ? "Saved card channel"
                                          : "Primary bank account",
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _method == "UPI"
                                      ? "student@upi"
                                      : _method == "Card"
                                          ? "Visa ending 4821"
                                          : "SBI x2213",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _amount,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black.withAlpha(10),
                      ),
                      child: Column(
                        children: [
                          _SummaryRow(label: "Fee payment", value: "Rs ${enteredAmount <= 0 ? 0 : enteredAmount}"),
                          const SizedBox(height: 6),
                          const _SummaryRow(label: "Platform fee", value: "Rs 0"),
                          const SizedBox(height: 6),
                          _SummaryRow(
                            label: "To be paid",
                            value: "Rs ${enteredAmount <= 0 ? 0 : enteredAmount}",
                            emphasize: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
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

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;

  const _InfoPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.black.withAlpha(14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.black.withAlpha(150), fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
      fontSize: emphasize ? 14 : 13,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}

class _PaymentSuccessSheet extends StatefulWidget {
  final int amount;
  final String method;

  const _PaymentSuccessSheet({
    required this.amount,
    required this.method,
  });

  @override
  State<_PaymentSuccessSheet> createState() => _PaymentSuccessSheetState();
}

class _PaymentSuccessSheetState extends State<_PaymentSuccessSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _check;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..forward();
    _scale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
    );
    _check = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    );
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    height: 92,
                    width: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [cs.primary, cs.secondary],
                      ),
                    ),
                    child: AnimatedBuilder(
                      animation: _check,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _TickPainter(progress: _check.value),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Payment Successful",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  "Rs ${widget.amount} paid via ${widget.method}",
                  style: TextStyle(color: Colors.black.withAlpha(170)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.green.withAlpha(15),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, color: Colors.green, size: 18),
                      SizedBox(width: 8),
                      Text("Dashboard will refresh instantly"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TickPainter extends CustomPainter {
  final double progress;

  const _TickPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final start = Offset(size.width * 0.28, size.height * 0.52);
    final mid = Offset(size.width * 0.45, size.height * 0.68);
    final end = Offset(size.width * 0.74, size.height * 0.34);

    if (progress <= 0.5) {
      final t = progress / 0.5;
      final current = Offset.lerp(start, mid, t) ?? mid;
      canvas.drawLine(start, current, paint);
      return;
    }

    canvas.drawLine(start, mid, paint);
    final t = (progress - 0.5) / 0.5;
    final current = Offset.lerp(mid, end, t) ?? end;
    canvas.drawLine(mid, current, paint);
  }

  @override
  bool shouldRepaint(covariant _TickPainter oldDelegate) => oldDelegate.progress != progress;
}

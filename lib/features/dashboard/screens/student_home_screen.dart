import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/view_state.dart';
import '../../payments/screens/payment_screen.dart';
import '../viewmodels/student_vm.dart';

class StudentHomeScreen extends StatefulWidget {
  final VoidCallback? onOpenHistory;
  const StudentHomeScreen({super.key, this.onOpenHistory});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentVm>().loadDashboard();
    });
  }

  Future<void> _openPay(int pendingFee) async {
    if (pendingFee <= 0) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaymentScreen(pendingAmount: pendingFee)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentVm>();
    final cs = Theme.of(context).colorScheme;
    final dash = vm.dashboard;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: vm.loadDashboard,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            children: [
              _TopStrip(colorScheme: cs),
              const SizedBox(height: 14),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: vm.dashboardState == ViewState.loading
                    ? const _LoadingShell(key: ValueKey("loading"))
                    : vm.dashboardState == ViewState.error
                        ? _ErrorShell(
                            key: const ValueKey("error"),
                            message: vm.dashboardError ?? "Unable to load dashboard",
                            onRetry: vm.loadDashboard,
                          )
                        : _BalanceShell(
                            key: const ValueKey("data"),
                            totalFee: dash.totalFee,
                            paidFee: dash.paidFee,
                            pendingFee: dash.pendingFee,
                            fineDue: dash.totalFineDue,
                            onPay: () => _openPay(dash.pendingFee),
                          ),
              ),
              const SizedBox(height: 14),
              _QuickGrid(
                onPay: () => _openPay(dash.pendingFee),
                onHistory: () => widget.onOpenHistory?.call(),
                onRefresh: vm.loadDashboard,
              ),
              if (dash.semesterBreakdown.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  "Semester Breakdown",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                ...dash.semesterBreakdown.map(
                  (s) => _SemesterCard(
                    title: s.semester,
                    paid: s.paid,
                    pending: s.pending,
                    fine: s.fineDue,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TopStrip extends StatelessWidget {
  final ColorScheme colorScheme;
  const _TopStrip({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.secondary]),
          ),
          child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Fee Wallet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              SizedBox(height: 2),
              Text("Scan-friendly, payment-first dashboard", style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class _BalanceShell extends StatelessWidget {
  final int totalFee;
  final int paidFee;
  final int pendingFee;
  final int fineDue;
  final VoidCallback onPay;

  const _BalanceShell({
    super.key,
    required this.totalFee,
    required this.paidFee,
    required this.pendingFee,
    required this.fineDue,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary.withAlpha(36), cs.tertiary.withAlpha(30), Theme.of(context).cardColor],
        ),
        border: Border.all(color: Colors.black.withAlpha(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Outstanding", style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text("Rs $pendingFee", style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _Pill(label: "Total", value: "Rs $totalFee")),
              const SizedBox(width: 8),
              Expanded(child: _Pill(label: "Paid", value: "Rs $paidFee")),
            ],
          ),
          if (fineDue > 0) ...[
            const SizedBox(height: 8),
            _Pill(label: "Fine Due", value: "Rs $fineDue", danger: true),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPay,
              icon: const Icon(Icons.payments_rounded),
              label: const Text("Pay Now"),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final String value;
  final bool danger;
  const _Pill({required this.label, required this.value, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final c = danger ? Colors.redAccent : Colors.black;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: c.withAlpha(15),
        border: Border.all(color: c.withAlpha(35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: c.withAlpha(160), fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _QuickGrid extends StatelessWidget {
  final VoidCallback onPay;
  final VoidCallback onHistory;
  final VoidCallback onRefresh;

  const _QuickGrid({required this.onPay, required this.onHistory, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Quick Actions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _ActionCard(icon: Icons.qr_code_scanner_rounded, label: "Pay", onTap: onPay)),
            const SizedBox(width: 8),
            Expanded(child: _ActionCard(icon: Icons.history_rounded, label: "History", onTap: onHistory)),
            const SizedBox(width: 8),
            Expanded(child: _ActionCard(icon: Icons.sync_rounded, label: "Refresh", onTap: onRefresh)),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Theme.of(context).cardColor,
          border: Border.all(color: Colors.black.withAlpha(16)),
        ),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SemesterCard extends StatelessWidget {
  final String title;
  final int paid;
  final int pending;
  final int fine;

  const _SemesterCard({required this.title, required this.paid, required this.pending, required this.fine});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.black.withAlpha(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text("Paid Rs $paid  •  Pending Rs $pending", style: const TextStyle(fontSize: 12)),
          if (fine > 0) Text("Fine Rs $fine", style: const TextStyle(fontSize: 12, color: Colors.redAccent)),
        ],
      ),
    );
  }
}

class _LoadingShell extends StatelessWidget {
  const _LoadingShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _ShimmerBox(height: 190),
        SizedBox(height: 10),
        _ShimmerBox(height: 66),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  const _ShimmerBox({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withAlpha(14),
      ),
    );
  }
}

class _ErrorShell extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorShell({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.black.withAlpha(16)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 34),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text("Retry")),
        ],
      ),
    );
  }
}

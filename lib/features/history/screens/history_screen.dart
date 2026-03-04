import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/view_state.dart';
import '../../dashboard/viewmodels/student_vm.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentVm>().loadPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentVm>();
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: vm.loadPayments,
        child: vm.paymentsState == ViewState.loading
            ? _loading()
            : vm.paymentsState == ViewState.error
                ? _error(vm)
                : _data(vm),
      ),
    );
  }

  Widget _loading() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SkeletonRow(),
        SizedBox(height: 10),
        _SkeletonRow(),
        SizedBox(height: 10),
        _SkeletonRow(),
      ],
    );
  }

  Widget _error(StudentVm vm) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.error_outline_rounded, size: 42),
        const SizedBox(height: 8),
        Text(vm.paymentsError ?? "Failed to load", textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Center(
          child: ElevatedButton.icon(
            onPressed: vm.loadPayments,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          ),
        ),
      ],
    );
  }

  Widget _data(StudentVm vm) {
    if (vm.payments.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 40),
          Icon(Icons.receipt_long_rounded, size: 44),
          SizedBox(height: 8),
          Text("No transactions yet", textAlign: TextAlign.center),
        ],
      );
    }

    final totalPaid = vm.payments.fold<int>(0, (sum, p) => sum + p.amount);
    final latest = vm.payments.first;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      itemCount: vm.payments.length + 2,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Transactions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryTile(
                        label: "Received",
                        value: "Rs $totalPaid",
                        accent: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryTile(
                        label: "Latest",
                        value: "Rs ${latest.amount}",
                        accent: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        if (i == 1) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              "Recent settlements",
              style: TextStyle(fontSize: 12, color: Colors.black.withAlpha(145), fontWeight: FontWeight.w700),
            ),
          );
        }
        final p = vm.payments[i - 2];
        final d = p.updatedAt;
        final date = "${d.day.toString().padLeft(2, "0")} ${_m(d.month)} ${d.year}";
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Theme.of(context).cardColor,
            border: Border.all(color: Colors.black.withAlpha(16)),
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.green.withAlpha(25),
                ),
                child: const Icon(Icons.check_rounded, color: Colors.green),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(date, style: TextStyle(fontSize: 12, color: Colors.black.withAlpha(140))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Rs ${p.amount}", style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.green.withAlpha(18),
                    ),
                    child: const Text(
                      "PAID",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static String _m(int m) {
    const n = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return n[m - 1];
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withAlpha(16),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: accent.withAlpha(18),
        border: Border.all(color: accent.withAlpha(36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: accent, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

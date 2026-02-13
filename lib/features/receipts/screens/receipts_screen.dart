import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/view_state.dart';
import '../../dashboard/viewmodels/student_vm.dart';

class ReceiptsScreen extends StatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentVm>().loadReceipts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentVm>();
    return Scaffold(
      appBar: AppBar(title: const Text("Receipts")),
      body: RefreshIndicator(
        onRefresh: vm.loadReceipts,
        child: _content(vm),
      ),
    );
  }

  Widget _content(StudentVm vm) {
    if (vm.receiptsState == ViewState.loading) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ReceiptSkeleton(),
          SizedBox(height: 10),
          _ReceiptSkeleton(),
        ],
      );
    }
    if (vm.receiptsState == ViewState.error) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.error_outline_rounded, size: 42),
          const SizedBox(height: 10),
          Text(vm.receiptsError ?? "Failed to load receipts", textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton.icon(
              onPressed: vm.loadReceipts,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ),
        ],
      );
    }
    if (vm.receipts.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 60),
          Icon(Icons.receipt_long_rounded, size: 48),
          SizedBox(height: 8),
          Text("No receipts available", textAlign: TextAlign.center),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.receipts.length,
      itemBuilder: (context, index) {
        final r = vm.receipts[index];
        final d = r.paidAt;
        final date = "${d.day.toString().padLeft(2, "0")}-${d.month.toString().padLeft(2, "0")}-${d.year}";
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.receipt_long_rounded),
            title: Text(r.receiptId, style: const TextStyle(fontWeight: FontWeight.w900)),
            subtitle: Text("${r.title}\n$date"),
            trailing: Text("Rs ${r.amount}", style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        );
      },
    );
  }
}

class _ReceiptSkeleton extends StatelessWidget {
  const _ReceiptSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.black.withAlpha(18)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/models/receipt_model.dart';
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

    final total = vm.receipts.fold<int>(0, (sum, item) => sum + item.amount);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.receipts.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _ReceiptHeader(total: total, count: vm.receipts.length);
        }
        final r = vm.receipts[index - 1];
        final d = r.paidAt;
        final date = "${d.day.toString().padLeft(2, "0")}/${d.month.toString().padLeft(2, "0")}/${d.year}";
        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _openReceipt(r),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withAlpha(18),
                  Theme.of(context).colorScheme.secondary.withAlpha(14),
                  Theme.of(context).cardColor,
                ],
              ),
              border: Border.all(color: Colors.black.withAlpha(14)),
            ),
            child: Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.green.withAlpha(18),
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(r.receiptId, style: TextStyle(fontSize: 12, color: Colors.black.withAlpha(145))),
                      const SizedBox(height: 3),
                      Text(date, style: TextStyle(fontSize: 12, color: Colors.black.withAlpha(145))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Rs ${r.amount}", style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.blue.withAlpha(18),
                      ),
                      child: const Text(
                        "VIEW",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openReceipt(ReceiptModel receipt) async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReceiptSheet(
        receipt: receipt,
        onShare: () => _shareReceipt(receipt),
        onPrint: () => _printReceipt(receipt),
      ),
    );
  }

  Future<void> _shareReceipt(ReceiptModel receipt) async {
    final text = _receiptText(receipt);
    await Share.share(text, subject: "College Fee Receipt ${receipt.receiptId}");
  }

  Future<void> _printReceipt(ReceiptModel receipt) async {
    final doc = pw.Document();
    final paidDate =
        "${receipt.paidAt.day.toString().padLeft(2, "0")}/${receipt.paidAt.month.toString().padLeft(2, "0")}/${receipt.paidAt.year}";
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Container(
          padding: const pw.EdgeInsets.all(28),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("College Fee Wallet", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text("Payment Receipt", style: const pw.TextStyle(fontSize: 16, color: PdfColors.blue700)),
              pw.SizedBox(height: 24),
              _pdfRow("Receipt ID", receipt.receiptId),
              _pdfRow("Title", receipt.title),
              _pdfRow("Amount", "Rs ${receipt.amount}"),
              _pdfRow("Paid On", paidDate),
              pw.SizedBox(height: 18),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.green50,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Text("Status: PAID"),
              ),
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: "receipt-${receipt.receiptId}.pdf",
    );
  }

  String _receiptText(ReceiptModel receipt) {
    final paidDate =
        "${receipt.paidAt.day.toString().padLeft(2, "0")}/${receipt.paidAt.month.toString().padLeft(2, "0")}/${receipt.paidAt.year}";
    return [
      "College Fee Wallet Receipt",
      "Receipt ID: ${receipt.receiptId}",
      "Title: ${receipt.title}",
      "Amount: Rs ${receipt.amount}",
      "Paid On: $paidDate",
      "Status: PAID",
    ].join("\n");
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 90,
            child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }
}

class _ReceiptHeader extends StatelessWidget {
  final int total;
  final int count;

  const _ReceiptHeader({
    required this.total,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withAlpha(34),
            cs.tertiary.withAlpha(24),
            Theme.of(context).cardColor,
          ],
        ),
        border: Border.all(color: Colors.black.withAlpha(14)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Receipt Vault", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text("$count receipts saved", style: TextStyle(color: Colors.black.withAlpha(150))),
              ],
            ),
          ),
          Text("Rs $total", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _ReceiptSheet extends StatelessWidget {
  final ReceiptModel receipt;
  final VoidCallback onShare;
  final VoidCallback onPrint;

  const _ReceiptSheet({
    required this.receipt,
    required this.onShare,
    required this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final paidDate =
        "${receipt.paidAt.day.toString().padLeft(2, "0")}/${receipt.paidAt.month.toString().padLeft(2, "0")}/${receipt.paidAt.year}";
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Payment Success", style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(
                        "Rs ${receipt.amount}",
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        receipt.title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _detail("Receipt ID", receipt.receiptId),
                _detail("Paid on", paidDate),
                _detail("Status", "PAID"),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onShare,
                        icon: const Icon(Icons.share_rounded),
                        label: const Text("Share"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onPrint,
                        icon: const Icon(Icons.print_rounded),
                        label: const Text("Print"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Done"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.black.withAlpha(150))),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _ReceiptSkeleton extends StatelessWidget {
  const _ReceiptSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 94,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.black.withAlpha(18)),
      ),
    );
  }
}

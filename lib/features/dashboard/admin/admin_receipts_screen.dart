import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';

class AdminReceiptsScreen extends StatefulWidget {
  const AdminReceiptsScreen({super.key});

  @override
  State<AdminReceiptsScreen> createState() => _AdminReceiptsScreenState();
}

class _AdminReceiptsScreenState extends State<AdminReceiptsScreen> {
  bool _loading = true;
  String? _error;
  List<_AdminReceipt> _receipts = const [];

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  Future<void> _loadReceipts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.get(AppConstants.adminReceipts, auth: true);
      final list = (res["receipts"] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_AdminReceipt.fromJson)
          .toList();
      if (!mounted) return;
      setState(() => _receipts = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _shareReceipt(_AdminReceipt receipt) async {
    await Share.share(_receiptText(receipt), subject: "Admin Receipt ${receipt.receiptId}");
  }

  Future<void> _printReceipt(_AdminReceipt receipt) async {
    final doc = pw.Document();
    final paidDate =
        "${receipt.updatedAt.day.toString().padLeft(2, "0")}/${receipt.updatedAt.month.toString().padLeft(2, "0")}/${receipt.updatedAt.year}";
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
              pw.Text("Admin Receipt Copy", style: const pw.TextStyle(fontSize: 16, color: PdfColors.blue700)),
              pw.SizedBox(height: 24),
              _pdfRow("Receipt ID", receipt.receiptId),
              _pdfRow("Student", receipt.studentEmail),
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
      name: "admin-receipt-${receipt.receiptId}.pdf",
    );
  }

  String _receiptText(_AdminReceipt receipt) {
    final paidDate =
        "${receipt.updatedAt.day.toString().padLeft(2, "0")}/${receipt.updatedAt.month.toString().padLeft(2, "0")}/${receipt.updatedAt.year}";
    return [
      "College Fee Wallet Admin Receipt",
      "Receipt ID: ${receipt.receiptId}",
      "Student: ${receipt.studentEmail}",
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

  Future<void> _openReceipt(_AdminReceipt receipt) async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AdminReceiptSheet(
        receipt: receipt,
        onShare: () => _shareReceipt(receipt),
        onPrint: () => _printReceipt(receipt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Receipts")),
      body: RefreshIndicator(
        onRefresh: _loadReceipts,
        child: _loading
            ? ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  _ReceiptSkeleton(),
                  SizedBox(height: 10),
                  _ReceiptSkeleton(),
                ],
              )
            : _error != null
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const SizedBox(height: 60),
                      const Icon(Icons.error_outline_rounded, size: 42),
                      const SizedBox(height: 10),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _loadReceipts,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _receipts.length,
                    itemBuilder: (context, index) {
                      final receipt = _receipts[index];
                      final d = receipt.updatedAt;
                      final date = "${d.day.toString().padLeft(2, "0")}/${d.month.toString().padLeft(2, "0")}/${d.year}";
                      return InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => _openReceipt(receipt),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: Theme.of(context).cardColor,
                            border: Border.all(color: Colors.black.withAlpha(14)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.green.withAlpha(18),
                                ),
                                child: const Icon(Icons.receipt_long_rounded, color: Colors.green),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(receipt.studentEmail, style: const TextStyle(fontWeight: FontWeight.w900)),
                                    const SizedBox(height: 3),
                                    Text(receipt.title, style: TextStyle(fontSize: 12, color: Colors.black.withAlpha(160))),
                                    const SizedBox(height: 3),
                                    Text(date, style: TextStyle(fontSize: 11, color: Colors.black.withAlpha(130))),
                                  ],
                                ),
                              ),
                              Text("Rs ${receipt.amount}", style: const TextStyle(fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class _AdminReceipt {
  final String receiptId;
  final String title;
  final int amount;
  final DateTime updatedAt;
  final String studentEmail;

  const _AdminReceipt({
    required this.receiptId,
    required this.title,
    required this.amount,
    required this.updatedAt,
    required this.studentEmail,
  });

  factory _AdminReceipt.fromJson(Map<String, dynamic> json) {
    return _AdminReceipt(
      receiptId: "RCPT-${json["id"]}",
      title: (json["title"] ?? "Payment").toString(),
      amount: int.tryParse((json["amount"] ?? 0).toString()) ?? 0,
      updatedAt: DateTime.tryParse((json["updatedAt"] ?? "").toString()) ?? DateTime.now(),
      studentEmail: (json["studentEmail"] ?? "Unknown").toString(),
    );
  }
}

class _AdminReceiptSheet extends StatelessWidget {
  final _AdminReceipt receipt;
  final VoidCallback onShare;
  final VoidCallback onPrint;

  const _AdminReceiptSheet({
    required this.receipt,
    required this.onShare,
    required this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final paidDate =
        "${receipt.updatedAt.day.toString().padLeft(2, "0")}/${receipt.updatedAt.month.toString().padLeft(2, "0")}/${receipt.updatedAt.year}";
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
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Receipt Copy", style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text("Rs ${receipt.amount}", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text(receipt.studentEmail, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _detail("Receipt ID", receipt.receiptId),
                _detail("Title", receipt.title),
                _detail("Paid on", paidDate),
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
          Expanded(child: Text(label, style: TextStyle(color: Colors.black.withAlpha(150)))),
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

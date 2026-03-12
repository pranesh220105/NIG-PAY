import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../admin/admin_add_fee_screen.dart';
import '../admin/admin_controls_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  bool _loading = true;
  String? _error;
  _AdminOverview _overview = const _AdminOverview.empty();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOverview();
    });
  }

  Future<void> _loadOverview() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.get(AppConstants.adminOverview, auth: true);
      if (!mounted) return;
      setState(() {
        _overview = _AdminOverview.fromJson(res);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst("Exception: ", "");
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadOverview,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            children: [
              _AdminHero(
                colorScheme: cs,
                studentCount: _overview.studentCount,
                collectedAmount: _overview.collectedAmount,
              ),
              const SizedBox(height: 14),
              if (_error != null)
                _ErrorCard(
                  message: _error!,
                  onRetry: _loadOverview,
                ),
              if (_error != null) const SizedBox(height: 14),
              _AdminStatsRow(
                loading: _loading,
                paidEntries: _overview.paidEntries,
                studentCount: _overview.studentCount,
                collectedAmount: _overview.collectedAmount,
              ),
              const SizedBox(height: 16),
              const Text(
                "Admin Actions",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.add_card_rounded,
                      title: "Add Fee",
                      subtitle: "Single student",
                      color: cs.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminAddFeeScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.groups_rounded,
                      title: "Manage",
                      subtitle: "Students + bulk fee",
                      color: cs.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminControlsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                "Recent Paid Fees",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              if (_loading)
                const _RecentSkeleton()
              else if (_overview.recentPayments.isEmpty)
                _EmptyRecentCard(onRefresh: _loadOverview)
              else
                ..._overview.recentPayments.map(
                  (payment) => _RecentPaymentTile(payment: payment),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminHero extends StatelessWidget {
  final ColorScheme colorScheme;
  final int studentCount;
  final int collectedAmount;

  const _AdminHero({
    required this.colorScheme,
    required this.studentCount,
    required this.collectedAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            const Color(0xFF4120B5),
            colorScheme.secondary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withAlpha(34),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Admin Control Center",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Track collections, assign dues, and review payment flow.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroPill(
                  label: "Students",
                  value: studentCount.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroPill(
                  label: "Collected",
                  value: "Rs $collectedAmount",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String label;
  final String value;

  const _HeroPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withAlpha(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _AdminStatsRow extends StatelessWidget {
  final bool loading;
  final int paidEntries;
  final int studentCount;
  final int collectedAmount;

  const _AdminStatsRow({
    required this.loading,
    required this.paidEntries,
    required this.studentCount,
    required this.collectedAmount,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Row(
        children: [
          Expanded(child: _StatSkeleton()),
          SizedBox(width: 10),
          Expanded(child: _StatSkeleton()),
          SizedBox(width: 10),
          Expanded(child: _StatSkeleton()),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: "Paid Entries",
            value: paidEntries.toString(),
            accent: const Color(0xFF6D46FF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: "Students",
            value: studentCount.toString(),
            accent: const Color(0xFF5B2BE0),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: "Collected",
            value: "Rs $collectedAmount",
            accent: const Color(0xFF8D6BFF),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: accent.withAlpha(16),
        border: Border.all(color: accent.withAlpha(30)),
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

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Theme.of(context).cardColor,
          border: Border.all(color: Colors.black.withAlpha(14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: color.withAlpha(16),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.black.withAlpha(150))),
          ],
        ),
      ),
    );
  }
}

class _RecentPaymentTile extends StatelessWidget {
  final _AdminRecentPayment payment;

  const _RecentPaymentTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    final d = payment.updatedAt;
    final date = "${d.day.toString().padLeft(2, "0")} ${_month(d.month)} ${d.year}";
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.black.withAlpha(14)),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.green.withAlpha(16),
            ),
            child: const Icon(Icons.check_circle_rounded, color: Colors.green),
            
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.studentEmail, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(payment.title, style: TextStyle(fontSize: 12, color: Colors.black.withAlpha(160))),
                const SizedBox(height: 3),
                Text(date, style: TextStyle(fontSize: 11, color: Colors.black.withAlpha(130))),
              ],
            ),
          ),
          Text("Rs ${payment.amount}", style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  static String _month(int month) {
    const names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return names[month - 1];
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.red.withAlpha(12),
        border: Border.all(color: Colors.red.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

class _EmptyRecentCard extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyRecentCard({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.black.withAlpha(14)),
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_rounded, size: 38),
          const SizedBox(height: 8),
          const Text("No paid fees recorded yet"),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.sync_rounded),
            label: const Text("Refresh"),
          ),
        ],
      ),
    );
  }
}

class _RecentSkeleton extends StatelessWidget {
  const _RecentSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _StatSkeleton(height: 84),
        SizedBox(height: 10),
        _StatSkeleton(height: 84),
      ],
    );
  }
}

class _StatSkeleton extends StatelessWidget {
  final double height;

  const _StatSkeleton({this.height = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.black.withAlpha(12),
      ),
    );
  }
}

class _AdminOverview {
  final int studentCount;
  final int collectedAmount;
  final int paidEntries;
  final List<_AdminRecentPayment> recentPayments;

  const _AdminOverview({
    required this.studentCount,
    required this.collectedAmount,
    required this.paidEntries,
    required this.recentPayments,
  });

  const _AdminOverview.empty()
      : studentCount = 0,
        collectedAmount = 0,
        paidEntries = 0,
        recentPayments = const [];

  factory _AdminOverview.fromJson(Map<String, dynamic> json) {
    final summary = (json["summary"] as Map<String, dynamic>? ?? const {});
    final recentRaw = json["recentPayments"] as List<dynamic>? ?? const [];
    int toInt(dynamic value) => int.tryParse(value.toString()) ?? 0;
    return _AdminOverview(
      studentCount: toInt(summary["studentCount"]),
      collectedAmount: toInt(summary["collectedAmount"]),
      paidEntries: toInt(summary["paidEntries"]),
      recentPayments: recentRaw
          .whereType<Map<String, dynamic>>()
          .map(_AdminRecentPayment.fromJson)
          .toList(),
    );
  }
}

class _AdminRecentPayment {
  final int id;
  final String title;
  final int amount;
  final String studentEmail;
  final DateTime updatedAt;

  const _AdminRecentPayment({
    required this.id,
    required this.title,
    required this.amount,
    required this.studentEmail,
    required this.updatedAt,
  });

  factory _AdminRecentPayment.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) => int.tryParse(value.toString()) ?? 0;
    return _AdminRecentPayment(
      id: toInt(json["id"]),
      title: (json["title"] ?? "Payment").toString(),
      amount: toInt(json["amount"]),
      studentEmail: (json["studentEmail"] ?? "Unknown").toString(),
      updatedAt: DateTime.tryParse(json["updatedAt"]?.toString() ?? "") ?? DateTime.now(),
    );
  }
}

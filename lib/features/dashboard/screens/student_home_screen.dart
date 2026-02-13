// lib/features/dashboard/screens/student_home_screen.dart

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  bool loading = true;
  String? error;

  int totalFee = 0;
  int paidFee = 0;
  int pendingFee = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await ApiService.get(AppConstants.studentDashboard, auth: true);

      final Map<String, dynamic> json =
          (res["data"] is Map<String, dynamic>) ? (res["data"] as Map<String, dynamic>) : res;

      int toInt(dynamic v) => int.tryParse(v.toString()) ?? 0;

      final t = toInt(json["totalFee"] ?? json["total"] ?? 0);
      final p = toInt(json["paidFee"] ?? json["paid"] ?? 0);
      final pend = toInt(json["pendingFee"] ?? json["pending"] ?? (t - p));

      setState(() {
        totalFee = t;
        paidFee = p;
        pendingFee = pend;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst("Exception: ", "");
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            children: [
              _HeaderCard(
                title: "Student Dashboard",
                subtitle: "Track your payments easily",
                icon: Icons.school_rounded,
                colorScheme: cs,
              ),
              const SizedBox(height: 14),

              if (loading) ...[
                _skeletonCard(),
                const SizedBox(height: 12),
                _skeletonCard(),
              ] else if (error != null) ...[
                _ErrorCard(message: error!, onRetry: _loadDashboard),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: "Total Fee",
                        value: "₹$totalFee",
                        icon: Icons.account_balance_wallet_rounded,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: "Paid",
                        value: "₹$paidFee",
                        icon: Icons.verified_rounded,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _BigStatCard(
                  title: "Pending",
                  value: "₹$pendingFee",
                  subtitle: pendingFee > 0 ? "Pay before due date to avoid fine" : "No pending fees 🎉",
                  color: Colors.orange,
                ),
              ],

              const SizedBox(height: 16),
              Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: _op(Colors.black, 0.75),
                ),
              ),
              const SizedBox(height: 10),

              _ActionTile(
                icon: Icons.payment_rounded,
                title: "Pay Fees",
                subtitle: "UPI / Card / Netbanking",
                color: cs.primary,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Payment screen next ✅")),
                  );
                },
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.history_rounded,
                title: "Payment History",
                subtitle: "View transactions",
                color: cs.secondary,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("History screen next ✅")),
                  );
                },
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.receipt_long_rounded,
                title: "Receipts",
                subtitle: "Download receipts",
                color: cs.tertiary,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Receipts screen next ✅")),
                  );
                },
              ),

              const SizedBox(height: 18),
              Text(
                "Tip: Pull down to refresh",
                textAlign: TextAlign.center,
                style: TextStyle(color: _op(Colors.black, 0.5), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skeletonCard() {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        border: Border.all(color: _op(Colors.black, 0.06)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: _op(Colors.black, 0.05),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(height: 12, decoration: BoxDecoration(color: _op(Colors.black, 0.05), borderRadius: BorderRadius.circular(8))),
                const SizedBox(height: 10),
                Container(height: 12, width: 160, decoration: BoxDecoration(color: _op(Colors.black, 0.05), borderRadius: BorderRadius.circular(8))),
              ],
            ),
          )
        ],
      ),
    );
  }

  static Color _op(Color c, double o) => c.withAlpha((o * 255).round());
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final ColorScheme colorScheme;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _op(colorScheme.primary, 0.20),
            _op(colorScheme.primaryContainer, 0.25),
            Colors.white,
          ],
        ),
        border: Border.all(color: _op(Colors.black, 0.06)),
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primaryContainer]),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: _op(Colors.black, 0.6), fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.sync_rounded, color: _op(Colors.black, 0.45)),
        ],
      ),
    );
  }

  Color _op(Color c, double o) => c.withAlpha((o * 255).round());
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        border: Border.all(color: _op(Colors.black, 0.06)),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: _op(color, 0.12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: _op(Colors.black, 0.6), fontWeight: FontWeight.w800, fontSize: 12)),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _op(Color c, double o) => c.withAlpha((o * 255).round());
}

class _BigStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _BigStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_op(color, 0.18), _op(color, 0.08)],
        ),
        border: Border.all(color: _op(Colors.black, 0.06)),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withAlpha(235),
            ),
            child: Icon(Icons.pending_actions_rounded, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: _op(Colors.black, 0.65), fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: _op(Colors.black, 0.6), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _op(Color c, double o) => c.withAlpha((o * 255).round());
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white,
          border: Border.all(color: _op(Colors.black, 0.06)),
        ),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: _op(color, 0.12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: _op(Colors.black, 0.6), fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  Color _op(Color c, double o) => c.withAlpha((o * 255).round());
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(color: _op(Colors.black, 0.06)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 42),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Color _op(Color c, double o) => c.withAlpha((o * 255).round());
}

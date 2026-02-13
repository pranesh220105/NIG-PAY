import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/dashboard_models.dart';
import '../../../core/services/api_service.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  bool loading = true;
  String? error;
  StudentDashboard data = const StudentDashboard(totalFee: 0, paidFee: 0, pendingFee: 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await ApiService.get(AppConstants.studentDashboard, auth: true);

      // Accept either direct numbers or nested object
      final dashJson = (res["data"] is Map<String, dynamic>) ? (res["data"] as Map<String, dynamic>) : res;

      setState(() {
        data = StudentDashboard.fromJson(dashJson);
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top header
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Student Dashboard",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: "Refresh",
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (error != null)
              Expanded(child: _ErrorView(message: error!, onRetry: _load))
            else
              Expanded(
                child: ListView(
                  children: [
                    // Summary cards
                    Row(
                      children: [
                        Expanded(child: _StatCard(title: "Total Fee", value: data.totalFee, icon: Icons.account_balance_wallet_rounded)),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(title: "Paid", value: data.paidFee, icon: Icons.verified_rounded)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _BigStatCard(
                      title: "Pending Fee",
                      value: data.pendingFee,
                      subtitle: "Pay before deadline to avoid fine",
                      icon: Icons.pending_actions_rounded,
                    ),

                    const SizedBox(height: 18),

                    // Actions (Buttons working)
                    Text("Quick Actions", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black.withOpacity(0.75))),
                    const SizedBox(height: 10),

                    _ActionButton(
                      icon: Icons.payment_rounded,
                      title: "Pay Now",
                      subtitle: "Make a fee payment",
                      color: cs.primary,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Pay Now screen can be added next (form + API).")),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _ActionButton(
                      icon: Icons.receipt_long_rounded,
                      title: "View Payment History",
                      subtitle: "See your past payments",
                      color: cs.secondary,
                      onTap: () {
                        // switch to History tab using bottom nav (simpler: show message here)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Go to History tab below ✅")),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _ActionButton(
                      icon: Icons.support_agent_rounded,
                      title: "Help & Support",
                      subtitle: "Contact admin for issues",
                      color: cs.tertiary,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Support screen can be added next.")),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withOpacity(0.05),
              ),
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text("₹ $value", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigStatCard extends StatelessWidget {
  final String title;
  final int value;
  final String subtitle;
  final IconData icon;
  const _BigStatCard({required this.title, required this.value, required this.subtitle, required this.icon});

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
          colors: [
            cs.primary.withOpacity(0.18),
            cs.primaryContainer.withOpacity(0.28),
          ],
        ),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withOpacity(0.8),
            ),
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.black.withOpacity(0.65), fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text("₹ $value", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.black.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: color.withOpacity(0.12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }
}

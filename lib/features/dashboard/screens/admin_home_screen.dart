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
  bool loading = false;
  String? lastMsg;

  Future<void> _ping() async {
    setState(() {
      loading = true;
      lastMsg = null;
    });
    try {
      await ApiService.get(AppConstants.studentDashboard, auth: true);
      setState(() => lastMsg = "Server connected");
    } catch (e) {
      setState(() => lastMsg = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          children: [
            _AdminHeader(colorScheme: cs),
            const SizedBox(height: 14),
            if (lastMsg != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: _op(Colors.black, 0.06)),
                ),
                child: Text(lastMsg!, style: TextStyle(color: _op(Colors.black, 0.75))),
              ),
            const SizedBox(height: 14),
            Text(
              "Admin Actions",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: _op(Colors.black, 0.75),
              ),
            ),
            const SizedBox(height: 10),
            _AdminActionTile(
              icon: Icons.add_card_rounded,
              title: "Add Fee",
              subtitle: "Add fee record for a student",
              color: cs.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminAddFeeScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            _AdminActionTile(
              icon: Icons.manage_accounts_rounded,
              title: "Manage Students",
              subtitle: "Create students and manage dues",
              color: cs.secondary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminControlsScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            _AdminActionTile(
              icon: Icons.cloud_done_rounded,
              title: "Test Server Connection",
              subtitle: "Ping backend",
              color: cs.tertiary,
              onTap: loading ? () {} : _ping,
              trailing: loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  static Color _op(Color c, double o) => c.withAlpha((o * 255).round());
}

class _AdminHeader extends StatelessWidget {
  final ColorScheme colorScheme;
  const _AdminHeader({required this.colorScheme});

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
            Theme.of(context).cardColor,
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
            child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Admin Dashboard", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text("Manage fee records and students", style: TextStyle(color: _op(Colors.black, 0.6), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _op(Color c, double o) => c.withAlpha((o * 255).round());
}

class _AdminActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;

  const _AdminActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.trailing,
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
          color: Theme.of(context).cardColor,
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
            trailing ?? const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  Color _op(Color c, double o) => c.withAlpha((o * 255).round());
}

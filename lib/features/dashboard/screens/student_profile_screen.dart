import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/session_service.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  String email = "-";
  String role = "-";
  bool _remindersEnabled = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final e = await SessionService.getEmail();
    final r = await SessionService.getRole();
    if (!mounted) return;
    setState(() {
      email = e ?? "-";
      role = r ?? "-";
    });
  }

  Future<void> _copyEmail() async {
    await Clipboard.setData(ClipboardData(text: email));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Email copied")),
    );
  }

  Future<void> _showInfoSheet({
    required String title,
    required String body,
    IconData icon = Icons.info_outline_rounded,
  }) async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: cs.primary.withAlpha(18),
                      ),
                      child: Icon(icon, color: cs.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(body, style: TextStyle(color: Colors.black.withAlpha(180), height: 1.35)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final initials = email != "-" && email.isNotEmpty ? email[0].toUpperCase() : "S";
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Account", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primary.withAlpha(48),
                  cs.secondary.withAlpha(32),
                  cs.tertiary.withAlpha(24),
                ],
              ),
              border: Border.all(color: Colors.black.withAlpha(12)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(role, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 3),
                          Text(email, style: TextStyle(color: Colors.black.withAlpha(170))),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: Colors.white.withAlpha(180),
                            ),
                            child: const Text(
                              "UPI-ready account",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MiniActionButton(
                        icon: Icons.copy_rounded,
                        label: "Copy Email",
                        onTap: _copyEmail,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniActionButton(
                        icon: Icons.sync_rounded,
                        label: "Refresh",
                        onTap: _load,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ProfileStat(
                  title: "Security",
                  value: "JWT Active",
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ProfileStat(
                  title: "Alerts",
                  value: _remindersEnabled ? "On" : "Off",
                  color: cs.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text("Preferences", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          _InteractiveOptionTile(
            icon: Icons.notifications_active_outlined,
            title: "Notifications",
            subtitle: _remindersEnabled ? "Payment reminders enabled" : "Payment reminders paused",
            trailing: Switch(
              value: _remindersEnabled,
              onChanged: (v) => setState(() => _remindersEnabled = v),
            ),
            onTap: () => setState(() => _remindersEnabled = !_remindersEnabled),
          ),
          _InteractiveOptionTile(
            icon: Icons.lock_outline_rounded,
            title: "Security",
            subtitle: "Session and token protection",
            onTap: () => _showInfoSheet(
              title: "Security",
              icon: Icons.lock_outline_rounded,
              body:
                  "This app stores the JWT in secure storage, checks token expiry before protected calls, and logs out automatically on 401 responses.",
            ),
          ),
          _InteractiveOptionTile(
            icon: Icons.support_agent_rounded,
            title: "Help & Support",
            subtitle: "Contact admin or raise an issue",
            onTap: () => _showInfoSheet(
              title: "Help & Support",
              icon: Icons.support_agent_rounded,
              body:
                  "For payment mismatches, open the History tab and match the latest receipt amount. If the due is incorrect, contact the admin account from the same system.",
            ),
          ),
          _InteractiveOptionTile(
            icon: Icons.account_balance_wallet_outlined,
            title: "Wallet Features",
            subtitle: "Fast pay, live history, auto refresh",
            onTap: () => _showInfoSheet(
              title: "Wallet Features",
              icon: Icons.account_balance_wallet_outlined,
              body:
                  "Your student wallet includes instant due refresh after payment, real transaction history, semester-wise progress, and fine tracking in one flow.",
            ),
          ),
          _InteractiveOptionTile(
            icon: Icons.info_outline_rounded,
            title: "About",
            subtitle: "College Fee Wallet v1.0",
            onTap: () => _showInfoSheet(
              title: "About",
              icon: Icons.info_outline_rounded,
              body:
                  "College Fee Wallet is a Flutter app with a Render-hosted Node/Express backend, Prisma ORM, PostgreSQL, JWT auth, and Provider-based state management.",
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MiniActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withAlpha(165),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _ProfileStat({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: color.withAlpha(16),
        border: Border.all(color: color.withAlpha(36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _InteractiveOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _InteractiveOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.black.withAlpha(16)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Theme.of(context).colorScheme.primary.withAlpha(14),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

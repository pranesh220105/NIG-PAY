import 'package:flutter/material.dart';

import '../../../core/services/session_service.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  String email = "-";
  String role = "-";

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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Account", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: [cs.primary.withAlpha(34), cs.secondary.withAlpha(28)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.black.withAlpha(16)),
            ),
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                  ),
                  child: Icon(Icons.person_rounded, color: cs.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(role, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Text(email, style: TextStyle(color: Colors.black.withAlpha(160))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text("Preferences", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          const _OptionTile(icon: Icons.notifications_none_rounded, title: "Notifications", subtitle: "Payment reminders"),
          const _OptionTile(icon: Icons.lock_outline_rounded, title: "Security", subtitle: "Pin and session settings"),
          const _OptionTile(icon: Icons.support_agent_rounded, title: "Help & Support", subtitle: "Contact admin"),
          const _OptionTile(icon: Icons.info_outline_rounded, title: "About", subtitle: "College Fee Wallet v1.0"),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.black.withAlpha(16)),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

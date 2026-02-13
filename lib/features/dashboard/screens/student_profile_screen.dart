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
    setState(() {
      email = e ?? "-";
      role = r ?? "-";
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Profile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.white,
                border: Border.all(color: _op(Colors.black, 0.06)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: _op(cs.primary, 0.12),
                    ),
                    child: Icon(Icons.person_rounded, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(role, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(email, style: TextStyle(color: _op(Colors.black, 0.65))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "More profile options can be added here (edit profile, change password, etc.)",
              style: TextStyle(color: _op(Colors.black, 0.55), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ avoid deprecated withOpacity()
  Color _op(Color c, double opacity) => c.withAlpha((opacity * 255).round());
}

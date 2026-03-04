import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../auth/login_screen.dart';
import '../history/screens/history_screen.dart';
import '../receipts/screens/receipts_screen.dart';
import 'screens/student_home_screen.dart';
import 'screens/student_profile_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int index = 0;

  void _openHistoryTab() {
    setState(() => index = 1);
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      StudentHomeScreen(onOpenHistory: _openHistoryTab),
      const HistoryScreen(),
      const ReceiptsScreen(),
      const StudentProfileScreen(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey(index),
          child: pages[index],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withAlpha(14),
              Theme.of(context).colorScheme.secondary.withAlpha(12),
            ],
          ),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: "Dashboard"),
            NavigationDestination(icon: Icon(Icons.receipt_long_rounded), label: "History"),
            NavigationDestination(icon: Icon(Icons.confirmation_number_rounded), label: "Receipts"),
            NavigationDestination(icon: Icon(Icons.person_rounded), label: "Profile"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logout,
        icon: const Icon(Icons.logout_rounded),
        label: const Text("Logout"),
      ),
    );
  }
}

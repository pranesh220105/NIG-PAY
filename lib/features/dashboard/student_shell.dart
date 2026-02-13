// lib/features/dashboard/student_shell.dart

import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
import '../../core/services/auth_service.dart';
import 'screens/student_home_screen.dart';
import 'screens/student_profile_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int index = 0;

  late final List<Widget> pages = const [
    StudentHomeScreen(),
    _StudentHistoryPlaceholder(),
    StudentProfileScreen(),
  ];

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
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            label: "Dashboard",
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_rounded),
            label: "History",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logout,
        icon: const Icon(Icons.logout_rounded),
        label: const Text("Logout"),
      ),
    );
  }
}

class _StudentHistoryPlaceholder extends StatelessWidget {
  const _StudentHistoryPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          "History Screen (Next)",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: _op(Colors.black, 0.7),
          ),
        ),
      ),
    );
  }

  Color _op(Color c, double o) => c.withAlpha((o * 255).round());
}

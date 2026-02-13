// lib/features/dashboard/admin_shell.dart

import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
import '../../core/services/auth_service.dart';
import 'screens/admin_home_screen.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const AdminHomeScreen(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _logout(context),
        icon: const Icon(Icons.logout_rounded),
        label: const Text("Logout"),
      ),
    );
  }
}

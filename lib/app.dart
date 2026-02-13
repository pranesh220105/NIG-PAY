import 'package:flutter/material.dart';

import 'core/services/session_service.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/student_shell.dart';
import 'features/dashboard/admin_shell.dart';

class FeeWalletApp extends StatelessWidget {
  const FeeWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "College Fee Wallet",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4F46E5),
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _op(Colors.black, 0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _op(Colors.black, 0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _op(Colors.black, 0.25)),
          ),
        ),
      ),
      home: const _Bootstrap(),
    );
  }

  // replaces deprecated withOpacity()
  static Color _op(Color c, double opacity) => c.withAlpha((opacity * 255).round());
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  bool loading = true;
  String? role;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final r = await SessionService.getRole();
    setState(() {
      role = r;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (role == "ADMIN") return const AdminShell();
    if (role == "STUDENT") return const StudentShell();
    return const LoginScreen();
  }
}

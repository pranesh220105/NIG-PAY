// lib/features/auth/login_screen.dart

import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../dashboard/student_shell.dart';
import '../dashboard/admin_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  String role = "STUDENT"; // ✅ required by backend
  bool loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => loading = true);

    try {
      await AuthService.login(
        email: _email.text.trim(),
        password: _password.text,
        role: role,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => role == "ADMIN" ? const AdminShell() : const StudentShell(),
        ),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _op(cs.primary, 0.18),
              _op(cs.primaryContainer, 0.10),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: _op(Colors.black, 0.06)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: LinearGradient(
                                    colors: [cs.primary, cs.primaryContainer],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("College Fee Wallet",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                                    SizedBox(height: 2),
                                    Text("Login to continue", style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // ✅ Role (backend requires it)
                          DropdownButtonFormField<String>(
                            value: role,
                            items: const [
                              DropdownMenuItem(value: "STUDENT", child: Text("Student")),
                              DropdownMenuItem(value: "ADMIN", child: Text("Admin")),
                            ],
                            onChanged: loading ? null : (v) => setState(() => role = v ?? "STUDENT"),
                            decoration: const InputDecoration(
                              labelText: "Role",
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _email,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(Icons.mail_outline),
                            ),
                            validator: (value) {
                              final v = (value ?? "").trim();
                              if (v.isEmpty) return "Enter email";
                              if (!v.contains("@")) return "Enter valid email";
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _password,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Password",
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            validator: (value) {
                              if ((value ?? "").length < 4) return "Enter valid password";
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: loading ? null : _login,
                              icon: loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.login),
                              label: const Text("Login"),
                            ),
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: loading
                                      ? null
                                      : () {
                                          setState(() => role = "STUDENT");
                                          _email.text = "student@test.com";
                                          _password.text = "123456";
                                        },
                                  child: const Text("Fill Student"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: loading
                                      ? null
                                      : () {
                                          setState(() => role = "ADMIN");
                                          _email.text = "admin@test.com";
                                          _password.text = "123456";
                                        },
                                  child: const Text("Fill Admin"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ avoid deprecated withOpacity()
  Color _op(Color c, double opacity) => c.withAlpha((opacity * 255).round());
}

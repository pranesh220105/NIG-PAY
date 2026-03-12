import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../dashboard/admin_shell.dart';
import '../dashboard/student_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  String role = "STUDENT";
  bool loading = false;
  static const bool _googleConfigured =
      bool.fromEnvironment("GOOGLE_SIGN_IN_ENABLED", defaultValue: true);

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _performLogin(
      email: _email.text.trim(),
      password: _password.text.trim(),
      loginRole: role,
    );
  }

  Future<void> _performLogin({
    required String email,
    required String password,
    required String loginRole,
  }) async {
    setState(() => loading = true);
    try {
      await AuthService.login(email: email, password: password, role: loginRole);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => loginRole == "ADMIN" ? const AdminShell() : const StudentShell(),
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

  Future<void> _googleSignIn() async {
    if (!_googleConfigured) {
      _showInfo("Google Sign-In is not enabled in this build.");
      return;
    }
    final pickedRole = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text("Sign in with Google", style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text("Choose role for this session"),
              ),
              ListTile(
                leading: const CircleAvatar(child: Text("S")),
                title: const Text("Student"),
                onTap: () => Navigator.pop(context, "STUDENT"),
              ),
              ListTile(
                leading: const CircleAvatar(child: Text("A")),
                title: const Text("Admin"),
                onTap: () => Navigator.pop(context, "ADMIN"),
              ),
            ],
          ),
        ),
      ),
    );
    if (pickedRole == null) return;
    setState(() => loading = true);
    try {
      await AuthService.signInWithGoogle(role: pickedRole);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => pickedRole == "ADMIN" ? const AdminShell() : const StudentShell(),
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

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF5B2BE0),
              const Color(0xFF7A4CFF),
              cs.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                    side: BorderSide(color: Colors.black.withAlpha(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 56,
                                width: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF5B2BE0), Color(0xFF7A4CFF)],
                                  ),
                                ),
                                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("College Fee Wallet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                                    SizedBox(height: 3),
                                    Text("Simple, secure and fast login"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          DropdownButtonFormField<String>(
                            initialValue: role,
                            decoration: const InputDecoration(
                              labelText: "Role",
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            items: const [
                              DropdownMenuItem(value: "STUDENT", child: Text("Student")),
                              DropdownMenuItem(value: "ADMIN", child: Text("Admin")),
                            ],
                            onChanged: loading ? null : (v) => setState(() => role = v ?? "STUDENT"),
                          ),
                          const SizedBox(height: 12),
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
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _password,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Password",
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            validator: (value) {
                              if ((value ?? "").trim().length < 4) return "Enter valid password";
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: loading ? null : _login,
                            icon: loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.login_rounded),
                            label: const Text("Login"),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: loading ? null : _googleSignIn,
                            icon: const Icon(Icons.g_mobiledata_rounded),
                            label: _googleConfigured
                                ? const Text("Sign in with Google")
                                : const Text("Google Sign-In Disabled"),
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
}

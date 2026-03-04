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
  bool _rememberMe = true;
  bool _useBiometricNext = false;
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
      password: _password.text,
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
      await AuthService.login(
        email: email,
        password: password,
        role: loginRole,
      );

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
      await _showInfoSheet(
        title: "Google Sign-In",
        icon: Icons.g_mobiledata_rounded,
        body:
            "Real Google Sign-In is disabled in this build. To enable it, run the app with GOOGLE_SIGN_IN_ENABLED=true and a valid GOOGLE_WEB_CLIENT_ID, and set GOOGLE_CLIENT_ID on the backend.",
      );
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Google Sign-In",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                "Choose the role for the Google account you want to use in this system.",
                style: TextStyle(color: Colors.black.withAlpha(170)),
              ),
              const SizedBox(height: 14),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: Theme.of(context).colorScheme.primary.withAlpha(10),
                leading: const CircleAvatar(child: Text("S")),
                title: const Text("Continue as Student"),
                subtitle: const Text("student@test.com"),
                onTap: () => Navigator.pop(context, "STUDENT"),
              ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: Theme.of(context).colorScheme.secondary.withAlpha(10),
                leading: const CircleAvatar(child: Text("A")),
                title: const Text("Continue as Admin"),
                subtitle: const Text("admin@test.com"),
                onTap: () => Navigator.pop(context, "ADMIN"),
              ),
            ],
          ),
        ),
      ),
    );
    if (pickedRole == null || !mounted) return;
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

  Future<void> _showInfoSheet({
    required String title,
    required String body,
    IconData icon = Icons.info_outline_rounded,
  }) async {
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
                        color: cs.primary.withAlpha(14),
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
                Text(body, style: TextStyle(color: Colors.black.withAlpha(175), height: 1.35)),
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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primary.withAlpha(28),
              cs.secondary.withAlpha(22),
              cs.tertiary.withAlpha(16),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 470),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                    side: BorderSide(color: _op(Colors.black, 0.06)),
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
                                height: 68,
                                width: 68,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  gradient: LinearGradient(
                                    colors: [cs.primary, cs.secondary],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "College Fee Wallet",
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Fast fee payments, secure login, and live academic dues.",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          DropdownButtonFormField<String>(
                            initialValue: role,
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
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  title: const Text("Remember me", style: TextStyle(fontSize: 13)),
                                  value: _rememberMe,
                                  onChanged: loading
                                      ? null
                                      : (v) => setState(() => _rememberMe = v ?? false),
                                ),
                              ),
                              TextButton(
                                onPressed: loading
                                    ? null
                                    : () => _showInfoSheet(
                                          title: "Forgot Password",
                                          icon: Icons.lock_reset_rounded,
                                          body:
                                              "This demo build does not include reset email flow yet. Use the admin panel to create a new temporary password or sign in with the demo account buttons.",
                                        ),
                                child: const Text("Forgot password?"),
                              ),
                            ],
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text("Use biometric next time"),
                            subtitle: const Text("Enable faster sign-in on this device"),
                            value: _useBiometricNext,
                            onChanged: loading ? null : (v) => setState(() => _useBiometricNext = v),
                          ),
                          const SizedBox(height: 8),
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
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: loading ? null : _googleSignIn,
                              icon: const _GoogleBadge(),
                              label: _googleConfigured
                                  ? const Text("Sign in with Google")
                                  : const Text("Google Sign-In (Setup Required)"),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.black.withAlpha(50))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "Quick access",
                                  style: TextStyle(color: Colors.black.withAlpha(140)),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.black.withAlpha(50))),
                            ],
                          ),
                          const SizedBox(height: 12),
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
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _MiniHelpChip(
                                icon: Icons.support_agent_rounded,
                                label: "Need help?",
                                onTap: () => _showInfoSheet(
                                  title: "Support",
                                  icon: Icons.support_agent_rounded,
                                  body:
                                      "Students can use the demo accounts for review. Admin can create real student accounts after login from the Admin Controls screen.",
                                ),
                              ),
                              _MiniHelpChip(
                                icon: Icons.security_rounded,
                                label: "Security",
                                onTap: () => _showInfoSheet(
                                  title: "Security",
                                  icon: Icons.security_rounded,
                                  body:
                                      "This app uses secure JWT storage, 401 auto logout, and token expiry checks before protected requests.",
                                ),
                              ),
                              _MiniHelpChip(
                                icon: Icons.info_outline_rounded,
                                label: "About app",
                                onTap: () => _showInfoSheet(
                                  title: "About",
                                  body:
                                      "College Fee Wallet is a Flutter-based fee management app with a Render-hosted Node/Express backend and PostgreSQL.",
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

  Color _op(Color c, double opacity) => c.withAlpha((opacity * 255).round());
}

class _GoogleBadge extends StatelessWidget {
  const _GoogleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      width: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withAlpha(30)),
      ),
      child: const Center(
        child: Text(
          "G",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _MiniHelpChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MiniHelpChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black.withAlpha(16)),
          color: Theme.of(context).cardColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

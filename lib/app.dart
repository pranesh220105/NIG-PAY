import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/repositories/student_repository.dart';
import 'core/state/theme_controller.dart';
import 'core/services/api_service.dart';
import 'core/services/session_service.dart';
import 'features/dashboard/viewmodels/student_vm.dart';
import 'features/auth/login_screen.dart';

class FeeWalletApp extends StatefulWidget {
  const FeeWalletApp({super.key});

  @override
  State<FeeWalletApp> createState() => _FeeWalletAppState();
}

class _FeeWalletAppState extends State<FeeWalletApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _navigatingToLogin = false;
  final ThemeController _themeController = ThemeController();

  @override
  void initState() {
    super.initState();
    ApiService.onUnauthorized = _handleUnauthorized;
    _themeController.load();
  }

  @override
  void dispose() {
    ApiService.onUnauthorized = null;
    super.dispose();
  }

  Future<void> _handleUnauthorized() async {
    if (_navigatingToLogin) return;
    _navigatingToLogin = true;
    await SessionService.clear();
    final nav = _navigatorKey.currentState;
    if (nav != null) {
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
    _navigatingToLogin = false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<StudentVm>(
          create: (_) => StudentVm(StudentRepository()),
        ),
        ChangeNotifierProvider<ThemeController>.value(
          value: _themeController,
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) => MaterialApp(
          navigatorKey: _navigatorKey,
          title: "College Fee Wallet",
          debugShowCheckedModeBanner: false,
          themeMode: themeController.mode,
          themeAnimationDuration: const Duration(milliseconds: 300),
          themeAnimationCurve: Curves.easeOutCubic,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          home: const LoginScreen(),
        ),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5B2BE0),
      brightness: brightness,
    ).copyWith(
      primary: isDark ? const Color(0xFF9C7FFF) : const Color(0xFF5B2BE0),
      secondary: isDark ? const Color(0xFF6D46FF) : const Color(0xFF7A4CFF),
      tertiary: isDark ? const Color(0xFFB197FF) : const Color(0xFFA688FF),
      surface: isDark ? const Color(0xFF120E27) : const Color(0xFFF7F5FF),
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: "sans-serif",
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: isDark ? const Color(0xFF090718) : const Color(0xFFF4F2FF),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF15112C) : Colors.white,
        elevation: 0,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF120D24) : Colors.white,
        indicatorColor: scheme.primary.withAlpha(isDark ? 52 : 32),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF132238) : const Color(0xFF16365F),
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1B1535) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _op(Colors.black, isDark ? 0.35 : 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _op(Colors.black, isDark ? 0.35 : 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _op(base.colorScheme.primary, 0.8)),
        ),
      ),
    );
  }

  static Color _op(Color c, double opacity) => c.withAlpha((opacity * 255).round());
}

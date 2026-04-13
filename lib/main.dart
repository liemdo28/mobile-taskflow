import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/secure_storage.dart';
import 'shared/providers.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait on phones, allow landscape on tablets
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style (dark)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF09090B),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Init local cache
  final cache = LocalCacheService();
  await cache.init();

  runApp(
    ProviderScope(
      overrides: [
        localCacheProvider.overrideWithValue(cache),
      ],
      child: const TaskFlowApp(),
    ),
  );
}

class TaskFlowApp extends ConsumerStatefulWidget {
  const TaskFlowApp({super.key});

  @override
  ConsumerState<TaskFlowApp> createState() => _TaskFlowAppState();
}

class _TaskFlowAppState extends ConsumerState<TaskFlowApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final storage = ref.read(secureStorageProvider);
    await storage.getDeviceId(); // Ensure device ID exists
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const Scaffold(
          backgroundColor: Color(0xFF09090B),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFFDC2626)),
          ),
        ),
      );
    }

    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', ''),
        Locale('en', ''),
      ],
      locale: const Locale('vi'),
      home: const AuthGate(),
    );
  }
}

/// AuthGate: check session → redirect to login or main
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Check session on startup
    Future.microtask(() => ref.read(authProvider.notifier).checkSession());
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return switch (auth.status) {
      AuthStatus.initial || AuthStatus.loading => const _SplashScreen(),
      AuthStatus.authenticated => const MainShell(),
      AuthStatus.unauthenticated || AuthStatus.error => const LoginPage(),
    };
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'TaskFlow',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

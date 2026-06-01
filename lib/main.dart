// PRODUCTION entry point.
// Run with:
//   flutter run --flavor prod -t lib/main.dart --dart-define=APP_FLAVOR=prod
//   flutter build apk --flavor prod -t lib/main.dart --dart-define=APP_FLAVOR=prod --release
//
// Also the default when running without any flavor flags (backward-compatible).
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/theme_provider.dart';
import 'core/router/app_router.dart';
import 'firebase_options_prod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: ProdFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
    // Native Firebase already initialised (hot-restart) — safe to continue.
  }
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp.router(
      title: 'M. A. Decorators',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

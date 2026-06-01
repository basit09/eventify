// DEV entry point.
// Run with:
//   flutter run --flavor dev -t lib/main_dev.dart --dart-define=APP_FLAVOR=dev
//   flutter build apk --flavor dev -t lib/main_dev.dart --dart-define=APP_FLAVOR=dev
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/flavor/app_flavor.dart';
import 'features/authentication/data/repositories/firebase_auth_repository.dart';
import 'features/category/data/repositories/firebase_category_repository.dart';
import 'firebase_options_dev.dart';

/// Name used for the named DEV Firebase app.
const _kDevAppName = 'dev';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sanity-check: this entry point should only run in dev flavor.
  assert(kIsDev, 'main_dev.dart was launched without --dart-define=APP_FLAVOR=dev');

  // The platform's native FirebaseInitProvider may have already initialized the
  // DEFAULT app using the prod GoogleService-Info.plist / google-services.json.
  // We CANNOT delete the default app on iOS, so instead we initialize a
  // separate NAMED 'dev' app and override every Firebase provider in ProviderScope.
  try {
    await Firebase.initializeApp(
      name: _kDevAppName,
      options: DevFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
    // Named 'dev' app already exists (hot-restart) — correct project, nothing to do.
  }

  final devApp = Firebase.app(_kDevAppName);

  // DEBUG — confirm we're on the right project.
  // ignore: avoid_print
  print('🔥 DEV Firebase app: ${devApp.options.projectId}');

  runApp(
    ProviderScope(
      overrides: [
        // Route every Firebase service call through the named 'dev' app.
        firebaseAuthProvider.overrideWithValue(
          FirebaseAuth.instanceFor(app: devApp),
        ),
        firebaseFirestoreProvider.overrideWithValue(
          FirebaseFirestore.instanceFor(app: devApp),
        ),
        firebaseStorageProvider.overrideWithValue(
          FirebaseStorage.instanceFor(app: devApp),
        ),
      ],
      child: const MyApp(),
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
      title: 'MA Decorators (DEV)',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      // ── DEV environment banner ─────────────────────────────────────────────
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    color: Colors.deepOrange.withValues(alpha: 0.88),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.science_outlined,
                                size: 12, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'DEV  ·  Firebase: event-management-dev',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

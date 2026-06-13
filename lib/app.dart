import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/env_service.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/theme_provider.dart';
import 'core/router/app_router.dart';

/// The single [MaterialApp] used by both prod and dev entry points.
///
/// [env] is passed in at build time by [AppRoot] — it drives the title
/// and the DEV overlay banner.
class MyApp extends ConsumerWidget {
  final AppEnvironment env;
  const MyApp({super.key, required this.env});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter  = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final isDev     = env == AppEnvironment.dev;

    return MaterialApp.router(
      title:                    isDev ? 'MA Decorators (DEV)' : 'M. A. Decorators',
      theme:                    AppTheme.lightTheme,
      darkTheme:                AppTheme.darkTheme,
      themeMode:                themeMode,
      routerConfig:             goRouter,
      debugShowCheckedModeBanner: false,
      // Show an orange DEV banner whenever the active env is dev,
      // regardless of which build flavor was used to compile the APK.
      builder: isDev
          ? (context, child) => Stack(
                children: [
                  child!,
                  Positioned(
                    top: 0, left: 0, right: 0,
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
                                      color:          Colors.white,
                                      fontSize:       10,
                                      fontWeight:     FontWeight.bold,
                                      decoration:     TextDecoration.none,
                                      letterSpacing:  0.5,
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
              )
          : null,
    );
  }
}

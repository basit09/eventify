import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../../app.dart';
import '../../bootstrap.dart';
import '../config/env_service.dart';

/// The true root of the widget tree.
///
/// Responsibilities:
///   • Calls [bootstrap] to initialise Firebase + resolve the active env.
///   • Wraps everything in a [ProviderScope] with the correct overrides.
///   • Exposes [AppRoot.switchEnv] — call this from the login screen to
///     atomically save the new env and rebuild the entire provider tree.
class AppRoot extends StatefulWidget {
  /// The default environment used on first launch (no saved preference).
  /// Pass [AppEnvironment.dev] from `main_dev.dart`,
  /// [AppEnvironment.prod] from `main.dart`.
  final AppEnvironment defaultEnv;

  const AppRoot({super.key, required this.defaultEnv});

  // ── Static access so the login screen can trigger a switch ───────────────

  static _AppRootState? _state;

  /// Switch to [newEnv], persist the preference, and rebuild the entire
  /// [ProviderScope] so every Firebase provider points to the new env.
  /// Safe to call only from the login screen (user is not authenticated).
  static Future<void> switchEnv(AppEnvironment newEnv) async {
    await EnvService.save(newEnv);
    _state?._restart();
  }

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  /// Incrementing this key destroys the old [ProviderScope] and creates a
  /// fresh one — every Riverpod provider is re-evaluated from scratch.
  int _scopeKey = 0;

  AppEnvironment _env = AppEnvironment.prod;
  List<Override> _overrides = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    AppRoot._state = this;
    _init();
  }

  @override
  void dispose() {
    if (AppRoot._state == this) AppRoot._state = null;
    super.dispose();
  }

  Future<void> _init() async {
    if (mounted) setState(() => _loading = true);

    final (env, overrides) = await bootstrap(defaultEnv: widget.defaultEnv);

    if (mounted) {
      setState(() {
        _env = env;
        _overrides = overrides;
        _loading = false;
      });
    }
  }

  void _restart() {
    setState(() => _scopeKey++);
    _init();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      // Shown only during the brief re-init on env switch (< 1 second).
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return ProviderScope(
      key: ValueKey(_scopeKey),
      overrides: _overrides,
      child: MyApp(env: _env),
    );
  }
}

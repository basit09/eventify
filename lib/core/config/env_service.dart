import 'package:shared_preferences/shared_preferences.dart';

/// Runtime environment — independent of the build flavor.
/// The build flavor sets the *default* env; the user can override it at runtime.
enum AppEnvironment { prod, dev }

/// Persists and retrieves the user-selected [AppEnvironment].
///
/// [load] must be awaited before [current] is called synchronously.
class EnvService {
  EnvService._();

  static const _key = 'selected_app_env';

  /// In-memory cache — set by [load] so the rest of the app can read
  /// the current env synchronously after bootstrap.
  static AppEnvironment _current = AppEnvironment.prod;

  /// The active environment. Valid after [load] has been awaited.
  static AppEnvironment get current => _current;

  /// Loads the saved environment from SharedPreferences.
  /// Falls back to [defaultEnv] on first launch (no saved value).
  static Future<AppEnvironment> load({
    AppEnvironment defaultEnv = AppEnvironment.prod,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    _current = raw == null
        ? defaultEnv
        : AppEnvironment.values.byName(raw);
    return _current;
  }

  /// Persists the chosen environment and updates the in-memory cache.
  static Future<void> save(AppEnvironment env) async {
    _current = env;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, env.name);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'core/config/env_service.dart';
import 'features/authentication/data/repositories/firebase_auth_repository.dart';
import 'features/category/data/repositories/firebase_category_repository.dart';
import 'firebase_options_dev.dart';
import 'firebase_options_prod.dart';

/// Initialises **both** Firebase apps and returns the correct
/// [ProviderScope] overrides for the resolved [AppEnvironment].
///
/// Always call this before [runApp].  Safe to call on hot-restart
/// (duplicate-app errors are swallowed).
Future<(AppEnvironment, List<Override>)> bootstrap({
  AppEnvironment defaultEnv = AppEnvironment.prod,
}) async {
  // ── 1. Init PROD default app ─────────────────────────────────────────────
  try {
    await Firebase.initializeApp(
      options: ProdFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  // ── 2. Init DEV named app ────────────────────────────────────────────────
  try {
    await Firebase.initializeApp(
      name: 'dev',
      options: DevFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  // ── 3. Resolve env (SharedPreferences → fallback to defaultEnv) ──────────
  final env = await EnvService.load(defaultEnv: defaultEnv);

  // ignore: avoid_print
  print('🔥 Active env: ${env.name}  '
      '(Firebase: ${env == AppEnvironment.dev ? Firebase.app("dev").options.projectId : Firebase.app().options.projectId})');

  return (env, _buildOverrides(env));
}

/// Builds the [ProviderScope] overrides that route every Firebase service
/// call through the correct Firebase app instance.
List<Override> _buildOverrides(AppEnvironment env) {
  if (env == AppEnvironment.dev) {
    final devApp = Firebase.app('dev');
    return [
      firebaseAuthProvider.overrideWithValue(
        FirebaseAuth.instanceFor(app: devApp),
      ),
      firebaseFirestoreProvider.overrideWithValue(
        FirebaseFirestore.instanceFor(app: devApp),
      ),
      firebaseStorageProvider.overrideWithValue(
        FirebaseStorage.instanceFor(app: devApp),
      ),
    ];
  }
  // prod → all providers use their default Firebase.instance values
  return const [];
}

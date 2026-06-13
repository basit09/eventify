// DEV entry point.
// flutter run  --flavor dev -t lib/main_dev.dart --dart-define=APP_FLAVOR=dev
// flutter build apk --flavor dev -t lib/main_dev.dart --dart-define=APP_FLAVOR=dev
import 'package:flutter/material.dart';

import 'core/config/env_service.dart';
import 'core/flavor/app_flavor.dart';
import 'core/widgets/app_root.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  assert(kIsDev, 'main_dev.dart launched without --dart-define=APP_FLAVOR=dev');
  runApp(const AppRoot(defaultEnv: AppEnvironment.dev));
}

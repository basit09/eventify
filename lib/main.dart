// PRODUCTION entry point.
// flutter run  --flavor prod -t lib/main.dart --dart-define=APP_FLAVOR=prod
// flutter build apk --flavor prod -t lib/main.dart --dart-define=APP_FLAVOR=prod --release
import 'package:flutter/material.dart';

import 'core/config/env_service.dart';
import 'core/widgets/app_root.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppRoot(defaultEnv: AppEnvironment.prod));
}

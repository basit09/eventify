/// Compile-time environment flag.
///
/// Set via --dart-define=APP_FLAVOR=dev  (dev build)
///          --dart-define=APP_FLAVOR=prod (prod build  — also the default)
///
/// Never changes at runtime; tree-shaken entirely in prod builds.
enum AppFlavor { dev, prod }

// String.fromEnvironment is a valid const expression; .byName() is not.
const String _flavorName =
    String.fromEnvironment('APP_FLAVOR', defaultValue: 'prod');

const AppFlavor kFlavor =
    _flavorName == 'dev' ? AppFlavor.dev : AppFlavor.prod;

/// True only in dev flavor builds — use this for banners, logging, etc.
const bool kIsDev = kFlavor == AppFlavor.dev;

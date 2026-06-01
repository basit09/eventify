plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.eventmanage.event_management"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.eventmanage.event_management"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ── Flavors ───────────────────────────────────────────────────────────────
    flavorDimensions += listOf("environment")

    productFlavors {
        create("dev") {
            dimension = "environment"
            // Separate app ID so dev & prod can be installed side-by-side
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            // Override app label shown on the home screen
            resValue("string", "app_name", "MA Decorators DEV")
        }
        create("prod") {
            dimension = "environment"
            // Prod uses the base applicationId — no suffix
            resValue("string", "app_name", "M. A. Decorators")
        }
    }
    // ─────────────────────────────────────────────────────────────────────────

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

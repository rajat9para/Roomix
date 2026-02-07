plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase Google Services plugin
    id("com.google.gms.google-services")
}

// Load local.properties for optional configuration
val localProperties = java.util.Properties()
val localPropertiesFile = rootProject.file("../android/local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(localPropertiesFile.inputStream())
}

// Compute MapMyIndia key once at configuration time so it can be used for
// manifestPlaceholders and also injected into Flutter dart defines.
val mapmyindiaKey: String = System.getenv("MAPMYINDIA_API_KEY")
    ?: localProperties.getProperty("mapmyindia.api.key", "")

// If running a release task, require that a MapMyIndia key is present to avoid
// shipping builds that will fail at runtime with missing map functionality.
val isReleaseBuild = gradle.startParameter.taskNames.any { it.contains("release", ignoreCase = true) }
if (isReleaseBuild && mapmyindiaKey.isEmpty()) {
    throw org.gradle.api.GradleException("MAPMYINDIA_API_KEY is required for release builds. Set MAPMYINDIA_API_KEY env var or add mapmyindia.api.key to android/local.properties.")
}

android {
    namespace = "com.company.roomix"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.company.roomix"
        // minSdk 23 required for Firebase Auth
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Enable multidex for Firebase
        multiDexEnabled = true

        // MapMyIndia API key injected into Android manifest via placeholders
        manifestPlaceholders["mapmyindiaApiKey"] = mapmyindiaKey
    }

    buildTypes {
        release {
            // Signing with debug keys for now
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

// Inject MAPMYINDIA_API_KEY as a compile-time Dart define if available. This makes
// keys stored in android/local.properties usable without extra CLI steps.
if (mapmyindiaKey.isNotEmpty()) {
    flutter {
        // Kotlin DSL: set extraDartDefines so the Flutter plugin appends them
        extraDartDefines = listOf("MAPMYINDIA_API_KEY=$mapmyindiaKey")
    }
}

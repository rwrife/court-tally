import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val releaseSigningEnabled = keystorePropertiesFile.isFile
if (releaseSigningEnabled) {
    keystorePropertiesFile.inputStream().use { stream ->
        keystoreProperties.load(stream)
    }
}

fun signingProperty(name: String): String =
    requireNotNull(keystoreProperties.getProperty(name)) {
        "Missing $name in android/key.properties"
    }

android {
    namespace = "com.rwrife.court_tally"
    // Pinned with Flutter 3.47.0; update deliberately with the SDK policy.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.rwrife.court_tally"
        minSdk = 24
        targetSdk = 36
        // Versions come from MAJOR.MINOR.PATCH+BUILD in pubspec.yaml.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseSigningEnabled) {
            create("release") {
                keyAlias = signingProperty("keyAlias")
                keyPassword = signingProperty("keyPassword")
                storeFile = rootProject.file(signingProperty("storeFile"))
                storePassword = signingProperty("storePassword")
            }
        }
    }

    buildTypes {
        getByName("release") {
            // CI intentionally omits key.properties and produces an unsigned AAB.
            // Release owners provide the ignored file on a protected signing host.
            if (releaseSigningEnabled) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

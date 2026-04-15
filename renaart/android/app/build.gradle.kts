import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// ── Keystore: local file หรือ CI env vars ────────────────────────────────────
val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keyPropertiesFile.inputStream().use { keyProperties.load(it) }
}

fun Properties.required(name: String): String =
    getProperty(name)?.takeIf { it.isNotBlank() }
        ?: error("Missing '$name' in android/key.properties")

android {
    namespace = "com.renaart.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.renaart.app"
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            when {
                // Local build — ใช้ key.properties
                keyPropertiesFile.exists() -> {
                    keyAlias = keyProperties.getProperty("keyAlias") ?: "upload"
                    keyPassword = keyProperties.required("keyPassword")
                    storeFile = file(keyProperties.required("storeFile"))
                    storePassword = keyProperties.required("storePassword")
                }
                // CI/CD — ใช้ environment variables
                System.getenv("KEYSTORE_PATH") != null -> {
                    keyAlias = System.getenv("KEY_ALIAS") ?: error("KEY_ALIAS not set")
                    keyPassword = System.getenv("KEY_PASSWORD") ?: error("KEY_PASSWORD not set")
                    storeFile = file(System.getenv("KEYSTORE_PATH")!!)
                    storePassword = System.getenv("STORE_PASSWORD") ?: error("STORE_PASSWORD not set")
                }
                else -> {
                    // Debug fallback — ป้องกัน build crash
                }
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
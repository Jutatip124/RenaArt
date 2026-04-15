import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// ── Release signing config (สร้างเพื่อรองรับการ Build ทั้งในเครื่องและบน Cloud) ────
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
    }

    signingConfigs {
        create("release") {
            if (keyPropertiesFile.exists()) {
                keyAlias = keyProperties.getProperty("keyAlias")?.takeIf { it.isNotBlank() } ?: "upload"
                keyPassword = keyProperties.required("keyPassword")
                // แก้ให้รองรับ Path ทั้งแบบรันในเครื่องและ GitHub Actions
                val storeFilePath = keyProperties.required("storeFile")
                storeFile = if (file(storeFilePath).exists()) {
                    file(storeFilePath)
                } else {
                    file("../$storeFilePath")
                }
                storePassword = keyProperties.required("storePassword")
            }
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
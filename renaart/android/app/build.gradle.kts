import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keyPropertiesFile.inputStream().use { keyProperties.load(it) }
}

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
            storeFile = file(
                keyProperties.getProperty("storeFile")
                    ?: System.getenv("KEYSTORE_PATH")
                    ?: error("storeFile not found in key.properties and KEYSTORE_PATH env var not set")
            )
            storePassword = keyProperties.getProperty("storePassword")
                ?: System.getenv("STORE_PASSWORD")
                ?: error("storePassword not found in key.properties and STORE_PASSWORD env var not set")
            keyAlias = keyProperties.getProperty("keyAlias")
                ?: System.getenv("KEY_ALIAS")
                ?: error("keyAlias not found in key.properties and KEY_ALIAS env var not set")
            keyPassword = keyProperties.getProperty("keyPassword")
                ?: System.getenv("KEY_PASSWORD")
                ?: error("keyPassword not found in key.properties and KEY_PASSWORD env var not set")
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
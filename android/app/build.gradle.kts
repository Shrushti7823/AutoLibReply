plugins {
    id("com.android.application")
    id("kotlin-android") // This applies the Kotlin Android plugin
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.autolibreply"
    compileSdk = 36
    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17 // Ensure this is set to Java 17
        targetCompatibility = JavaVersion.VERSION_17 // Ensure this is set to Java 17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString() // Ensure this is set to Java 17
    }

    defaultConfig {
        applicationId = "com.example.autolibreply"
        minSdk = flutter.minSdkVersion // Set your minimum SDK version
        targetSdk = 35 // Set your target SDK version
        versionCode = 1 // Update as needed
        versionName = "1.0" // Update as needed
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // Update with your signing config
        }
    }
}

flutter {
    source = "../.." // Path to your Flutter source
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.11.0"))
    implementation("com.google.firebase:firebase-analytics")
}

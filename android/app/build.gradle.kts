// 1. We move the plugins out of the top block to stop the 'Decorated' loop
apply(plugin = "com.android.application")
apply(plugin = "kotlin-android")
apply(plugin = "dev.flutter.flutter-gradle-plugin")
apply(plugin = "com.google.gms.google-services")

// 2. Break the directory calculation loop immediately
layout.buildDirectory.set(file("${project.projectDir}/build"))

android {
    // Required for AGP 8.0+
    namespace = "com.between.fracturedpromises"
    compileSdk = 34

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.between.fracturedpromises"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        // We use 'create' or direct access to avoid the AgpDecorated StackOverflow
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-analytics")
}

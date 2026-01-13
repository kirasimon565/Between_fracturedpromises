pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val localPropertiesFile = settingsDir.resolve("local.properties")
        
        if (localPropertiesFile.exists()) {
            localPropertiesFile.inputStream().use { properties.load(it) }
        }
        
        // Try to get flutter.sdk from local.properties first
        var path = properties.getProperty("flutter.sdk")
        
        // If not found, try environment variables
        if (path.isNullOrEmpty()) {
            path = System.getenv("FLUTTER_ROOT") ?: System.getenv("FLUTTER_HOME")
        }
        
        // Validate the path
        requireNotNull(path) { 
            "Flutter SDK not found. Set flutter.sdk in local.properties or FLUTTER_ROOT environment variable." 
        }
        
        // Verify the Flutter tools gradle directory exists
        val flutterToolsGradle = java.io.File(path, "packages/flutter_tools/gradle")
        require(flutterToolsGradle.exists()) {
            "Flutter tools gradle not found at: ${flutterToolsGradle.absolutePath}"
        }
        
        path
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
}

include(":app")

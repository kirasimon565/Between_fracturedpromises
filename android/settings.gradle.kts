import java.util.Properties
import java.io.File

pluginManagement {
    val flutterSdkPath = run {
        // Using the full path to the class to bypass "Unresolved Reference"
        val properties = java.util.Properties() 
        val localPropertiesFile = settingsDir.resolve("local.properties")
        if (localPropertiesFile.exists()) {
            localPropertiesFile.inputStream().use { properties.load(it) }
        }
        val path = properties.getProperty("flutter.sdk")
        requireNotNull(path) { "flutter.sdk not set in local.properties" }
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
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
    id("com.android.application") version "8.1.1" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
    id("com.google.gms.google-services") version "4.3.15" apply false
}

include(":app")

// Fully qualified names here as well for safety
val flutterProjectRoot = settingsDir.parentFile.toPath()
val pluginsFile = java.io.File(flutterProjectRoot.toFile(), ".flutter-plugins")
if (pluginsFile.exists()) {
    val pluginsProperties = java.util.Properties()
    pluginsFile.inputStream().use { pluginsProperties.load(it) }
    pluginsProperties.forEach { name, path ->
        val pluginDirectory = flutterProjectRoot.resolve(path.toString()).resolve("android").toFile()
        if (pluginDirectory.exists()) {
            include(":$name")
            project(":$name").projectDir = pluginDirectory
        }
    }
}

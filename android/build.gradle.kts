// android/build.gradle.kts
// Root build.gradle.kts (fixed: no afterEvaluate, no evaluationDependsOn)

import com.android.build.api.dsl.CommonExtension
import org.gradle.api.Project
import org.gradle.api.tasks.Delete
import org.gradle.kotlin.dsl.findByType
import org.gradle.kotlin.dsl.register

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

/**
 * ✅ AGP 8+ requires "namespace" for every Android module.
 * Some pub packages ship without it (ex: isar_flutter_libs), which breaks the build.
 *
 * This applies a fallback namespace ONLY if the module doesn't already have one.
 * IMPORTANT: This runs when the Android plugin is applied (safe), not afterEvaluate (unsafe on Gradle 9+).
 */
fun Project.applyNamespaceFallback() {
    // CommonExtension covers both application & library Android modules
    val androidExt = extensions.findByType<CommonExtension<*, *, *, *, *>>() ?: return

    val current = androidExt.namespace
    if (!current.isNullOrBlank()) return

    val fallback = when (name) {
        "isar_flutter_libs" -> "dev.isar.isar_flutter_libs"
        else -> "com.between.${name.replace('-', '_')}"
    }

    androidExt.namespace = fallback
}

subprojects {

    // Apply only to Android modules, as soon as the plugin is applied
    plugins.withId("com.android.application") {
        project.applyNamespaceFallback()
    }

    plugins.withId("com.android.library") {
        project.applyNamespaceFallback()
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

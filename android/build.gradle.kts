// android/build.gradle.kts
// Root build.gradle.kts (production-safe: no afterEvaluate, reflection-based namespace fallback)

import org.gradle.api.Project
import org.gradle.api.tasks.Delete
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
 * This sets a fallback namespace ONLY if the module doesn't already have one.
 *
 * IMPORTANT:
 * - No afterEvaluate (Gradle 9+ can throw hard)
 * - Runs when Android plugin is applied (safe lifecycle)
 * - Uses reflection so it works across AGP minor versions and app/library modules
 */
fun Project.applyNamespaceFallbackReflective() {
    // Find the "android" extension (exists for com.android.application/library modules)
    val androidExt = extensions.findByName("android") ?: return

    // AGP exposes getNamespace()/setNamespace(String) on the android extension
    val getNamespace = androidExt.javaClass.methods.firstOrNull { it.name == "getNamespace" }
    val setNamespace = androidExt.javaClass.methods.firstOrNull { it.name == "setNamespace" }

    // If AGP type doesn't support namespace (very old AGP), do nothing
    if (setNamespace == null) return

    val current = (getNamespace?.invoke(androidExt) as? String).orEmpty()
    if (current.isNotBlank()) return

    val fallback = when (name) {
        "isar_flutter_libs" -> "dev.isar.isar_flutter_libs"
        else -> "com.between.${name.replace('-', '_')}"
    }

    setNamespace.invoke(androidExt, fallback)
    // Optional debug:
    // println("✅ namespace fallback applied for $path -> $fallback")
}

subprojects {

    // Apply only to Android modules, at plugin-apply time (safe)
    plugins.withId("com.android.application") {
        project.applyNamespaceFallbackReflective()
    }

    plugins.withId("com.android.library") {
        project.applyNamespaceFallbackReflective()
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

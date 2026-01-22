// android/build.gradle.kts
// Root build.gradle.kts (production-safe: no afterEvaluate, reflection-based namespace fallback + force compileSdk)

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
}

/**
 * ✅ Forces compileSdk for ALL Android modules (app + libraries).
 *
 * Fixes errors like:
 *   AAPT: error: resource android:attr/lStar not found
 *
 * Why it happens:
 * - Your :app can be compileSdk 36
 * - But a plugin module (ex: isar_flutter_libs) can still compile with < 31
 * - AAPT then can't find android:attr/lStar (API 31+)
 *
 * IMPORTANT:
 * - No afterEvaluate
 * - Runs at plugin-apply time
 * - Reflection so it works across AGP versions
 */
fun Project.forceCompileSdk(api: Int) {
    val androidExt = extensions.findByName("android") ?: return

    // Different AGP versions expose either:
    // - setCompileSdkVersion(Int)
    // - compileSdkVersion(Int)
    val setCompileSdk = androidExt.javaClass.methods.firstOrNull {
        it.name == "setCompileSdkVersion" && it.parameterTypes.size == 1
    }
    val compileSdkVersion = androidExt.javaClass.methods.firstOrNull {
        it.name == "compileSdkVersion" && it.parameterTypes.size == 1
    }

    when {
        setCompileSdk != null -> setCompileSdk.invoke(androidExt, api)
        compileSdkVersion != null -> compileSdkVersion.invoke(androidExt, api)
    }
}

subprojects {

    // Apply only to Android modules, at plugin-apply time (safe)
    plugins.withId("com.android.application") {
        project.applyNamespaceFallbackReflective()
        project.forceCompileSdk(36)
    }

    plugins.withId("com.android.library") {
        project.applyNamespaceFallbackReflective()
        project.forceCompileSdk(36)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

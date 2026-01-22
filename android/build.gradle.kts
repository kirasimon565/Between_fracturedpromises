// android/build.gradle.kts
// Root build.gradle.kts (production-safe: no afterEvaluate, reflection-based namespace fallback + safe compileSdk forcing)

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
 * - No afterEvaluate
 * - Runs when Android plugin is applied (safe lifecycle)
 * - Uses reflection so it works across AGP minor versions/types
 */
fun Project.applyNamespaceFallbackReflective() {
    val androidExt = extensions.findByName("android") ?: return

    val getNamespace = androidExt.javaClass.methods.firstOrNull { it.name == "getNamespace" }
    val setNamespace = androidExt.javaClass.methods.firstOrNull { it.name == "setNamespace" && it.parameterTypes.size == 1 }
        ?: return

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
 * Fixes: AAPT "android:attr/lStar not found" when a plugin compiles with < 31.
 *
 * IMPORTANT:
 * - No afterEvaluate
 * - Runs at plugin-apply time
 * - Reflection + overload-safe (Int vs String)
 * - Won't crash the build if AGP API differs
 */
fun Project.forceCompileSdk(api: Int) {
    val androidExt = extensions.findByName("android") ?: return

    fun invokeIfExists(methodName: String): Boolean {
        val candidates = androidExt.javaClass.methods.filter { it.name == methodName && it.parameterTypes.size == 1 }
        if (candidates.isEmpty()) return false

        // Prefer Int/Integer overloads
        val intMethod = candidates.firstOrNull { p ->
            val t = p.parameterTypes[0]
            t == Int::class.javaPrimitiveType || t == Integer::class.java
        }

        // Otherwise fall back to String overloads
        val stringMethod = candidates.firstOrNull { p -> p.parameterTypes[0] == String::class.java }

        return try {
            when {
                intMethod != null -> {
                    intMethod.invoke(androidExt, api)
                    true
                }
                stringMethod != null -> {
                    // AGP sometimes expects "android-34" style
                    stringMethod.invoke(androidExt, "android-$api")
                    true
                }
                else -> false
            }
        } catch (_: Throwable) {
            // Don't crash plugin application if AGP signature differs
            false
        }
    }

    // Different AGP versions use different names. Try all safe options.
    val applied =
        invokeIfExists("setCompileSdkVersion") ||
        invokeIfExists("compileSdkVersion") ||
        invokeIfExists("setCompileSdk") ||      // newer DSL uses compileSdk property; some expose setter
        invokeIfExists("compileSdk")            // sometimes a method exists too

    // Optional debug:
    // if (applied) println("✅ compileSdk forced for $path -> $api")
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

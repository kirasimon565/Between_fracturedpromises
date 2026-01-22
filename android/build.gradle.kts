// android/build.gradle.kts
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
 * ✅ Fixes missing "namespace" for older plugins (like isar_flutter_libs).
 */
fun Project.applyNamespaceFallbackReflective() {
    val androidExt = extensions.findByName("android") ?: return
    val getNamespace = androidExt.javaClass.methods.firstOrNull { it.name == "getNamespace" }
    val setNamespace = androidExt.javaClass.methods.firstOrNull { it.name == "setNamespace" && it.parameterTypes.size == 1 } ?: return

    val current = (getNamespace?.invoke(androidExt) as? String).orEmpty()
    if (current.isNotBlank()) return

    val fallback = when (name) {
        "isar_flutter_libs" -> "dev.isar.isar_flutter_libs"
        else -> "com.between.${name.replace('-', '_')}"
    }
    setNamespace.invoke(androidExt, fallback)
}

/**
 * ✅ Forces compileSdk for ALL modules (prevents lStar error at resource level).
 */
fun Project.forceCompileSdk(api: Int) {
    val androidExt = extensions.findByName("android") ?: return
    val targetMethods = androidExt.javaClass.methods.filter { 
        (it.name == "setCompileSdkVersion" || it.name == "compileSdkVersion" || it.name == "setCompileSdk" || it.name == "compileSdk") 
        && it.parameterTypes.size == 1 
    }

    targetMethods.forEach { method ->
        try {
            val type = method.parameterTypes[0]
            if (type == Int::class.javaPrimitiveType || type == Integer::class.java) {
                method.invoke(androidExt, api)
            } else if (type == String::class.java) {
                method.invoke(androidExt, "android-$api")
            }
        } catch (_: Throwable) {}
    }
}

subprojects {
    // 🚀 STEP 1: Force Isar to wait for the main app configuration
    if (project.name == "isar_flutter_libs") {
        evaluationDependsOn(":app")
    }

    // 🚀 STEP 2: Force modern AndroidX Core versions project-wide
    configurations.all {
        resolutionStrategy {
            eachDependency {
                if (requested.group == "androidx.core" && requested.name.contains("core")) {
                    useVersion("1.12.0") // Highly stable version with lStar support
                }
            }
        }
    }

    // 🚀 STEP 3: Apply fixes during the afterEvaluate phase for maximum override
    afterEvaluate {
        plugins.withId("com.android.application") {
            project.applyNamespaceFallbackReflective()
            project.forceCompileSdk(34) // 34 is the stable standard for now
        }

        plugins.withId("com.android.library") {
            project.applyNamespaceFallbackReflective()
            project.forceCompileSdk(34)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

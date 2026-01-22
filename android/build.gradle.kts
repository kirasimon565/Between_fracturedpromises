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
    // 🚀 THE MAGIC FIX: This forces the dependency version project-wide
    configurations.all {
        resolutionStrategy {
            eachDependency {
                if (requested.group == "androidx.core" && requested.name.contains("core")) {
                    // 1.10.1 is stable and supports lStar perfectly
                    useVersion("1.10.1")
                }
            }
        }
    }

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

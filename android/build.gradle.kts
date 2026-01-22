// Root build.gradle.kts
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
 * ✅ AGP 8+ requires "namespace". This sets a fallback for missing plugins.
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
 * ✅ Forces compileSdk for ALL modules to solve the lStar resource error.
 */
fun Project.forceCompileSdk(api: Int) {
    val androidExt = extensions.findByName("android") ?: return
    val methods = androidExt.javaClass.methods
    
    val targetMethods = methods.filter { 
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
    // 🚀 THE FIX: Force the correct version of AndroidX Core for the whole project
    configurations.all {
        resolutionStrategy {
            force("androidx.core:core:1.7.0")
            force("androidx.core:core-ktx:1.7.0")
        }
    }

    // Apply logic to Android Application and Library plugins
    plugins.withId("com.android.application") {
        project.applyNamespaceFallbackReflective()
        project.forceCompileSdk(34)
    }

    plugins.withId("com.android.library") {
        project.applyNamespaceFallbackReflective()
        project.forceCompileSdk(34)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Root build.gradle.kts
// Cleaned version to stop the StackOverflow loop

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// We remove the manual "layout.buildDirectory" remapping here.
// Gradle will use the default /build folders, which stops the recursion.

subprojects {
    project.evaluationDependsOn(":app")

    // ✅ AGP 8+ requires "namespace" for every Android module.
    // Some pub packages (like isar_flutter_libs) ship without it, which breaks the build.
    //
    // This block sets a fallback namespace ONLY if the module doesn't already have one.
    fun applyNamespaceFallback() {
        afterEvaluate {
            val androidExt = extensions.findByName("android") ?: return@afterEvaluate

            // Use reflection so this works across AGP versions/types (app/library)
            val getNamespace = androidExt.javaClass.methods.firstOrNull { it.name == "getNamespace" }
            val setNamespace = androidExt.javaClass.methods.firstOrNull { it.name == "setNamespace" }
                ?: return@afterEvaluate

            val current = getNamespace?.invoke(androidExt) as? String
            if (!current.isNullOrBlank()) return@afterEvaluate

            // Prefer a stable namespace. You can customize this.
            val fallback = when (project.name) {
                "isar_flutter_libs" -> "dev.isar.isar_flutter_libs"
                else -> "com.between.${project.name.replace('-', '_')}"
            }

            setNamespace.invoke(androidExt, fallback)
        }
    }

    // Apply only to Android modules
    plugins.withId("com.android.application") { applyNamespaceFallback() }
    plugins.withId("com.android.library") { applyNamespaceFallback() }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

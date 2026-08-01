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

// Keep Android/Gradle outputs in Flutter's canonical project-root build/
// directory. Flutter's build tooling looks for APKs at
// <project>/build/app/outputs/flutter-apk/ after :app:assembleRelease. If the
// Android project uses Gradle's default android/app/build/ location instead,
// assembleRelease can succeed while Flutter reports that no APK was produced.
val flutterBuildDir = rootProject.layout.projectDirectory.dir("../build")
rootProject.layout.buildDirectory.set(flutterBuildDir)

subprojects {
    project.layout.buildDirectory.set(flutterBuildDir.dir(project.name))
}

// The compile SDK every module is pinned to. Keep this equal to the app's
// `compileSdk` in app/build.gradle — a library compiled against an older SDK
// than the application's `targetSdkVersion` fails resource linking.
val projectCompileSdk = 36

/**
 * Some Flutter plugins still ship without an AGP 8 `namespace`. Rather than
 * pinning old plugin versions, derive one from the module name.
 */
fun Project.applyNamespaceFallbackReflective() {
    val androidExt = extensions.findByName("android") ?: return
    val getNamespace = androidExt.javaClass.methods.firstOrNull { it.name == "getNamespace" }
    val setNamespace = androidExt.javaClass.methods.firstOrNull {
        it.name == "setNamespace" && it.parameterTypes.size == 1
    } ?: return

    val current = (getNamespace?.invoke(androidExt) as? String).orEmpty()
    if (current.isNotBlank()) return

    setNamespace.invoke(androidExt, "com.between.${name.replace('-', '_')}")
}

/**
 * Forces a single compileSdk across every module so resource attributes such
 * as `lStar` resolve consistently.
 */
fun Project.forceCompileSdk(api: Int) {
    val androidExt = extensions.findByName("android") ?: return
    val targetMethods = androidExt.javaClass.methods.filter {
        (it.name == "setCompileSdkVersion" || it.name == "compileSdkVersion" ||
            it.name == "setCompileSdk" || it.name == "compileSdk") &&
            it.parameterTypes.size == 1
    }

    targetMethods.forEach { method ->
        try {
            val type = method.parameterTypes[0]
            if (type == Int::class.javaPrimitiveType || type == Integer::class.java) {
                method.invoke(androidExt, api)
            } else if (type == String::class.java) {
                method.invoke(androidExt, "android-$api")
            }
        } catch (_: Throwable) {
        }
    }
}

subprojects {
    // Modern AndroidX Core project-wide (lStar support).
    configurations.all {
        resolutionStrategy {
            eachDependency {
                if (requested.group == "androidx.core" && requested.name.contains("core")) {
                    useVersion("1.13.1")
                }
            }
        }
    }

    afterEvaluate {
        // The application module declares its own namespace and compileSdk in
        // app/build.gradle; only third-party library modules are patched.
        plugins.withId("com.android.library") {
            project.applyNamespaceFallbackReflective()
            project.forceCompileSdk(projectCompileSdk)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

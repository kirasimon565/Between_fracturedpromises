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
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

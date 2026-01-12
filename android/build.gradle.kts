// Root build.gradle.kts

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Fixed Directory Logic: Use the project name to prevent circular mapping
val rootBuildDir = rootProject.layout.buildDirectory.dir("../../build")
rootProject.layout.buildDirectory.set(rootBuildDir)

subprojects {
    val subprojectBuildDir = rootProject.layout.buildDirectory.dir(project.name)
    project.layout.buildDirectory.set(subprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

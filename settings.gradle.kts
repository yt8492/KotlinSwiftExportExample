rootProject.name = "KotlinSwiftExportExample"

pluginManagement {
    repositories {
        maven("https://packages.jetbrains.team/maven/p/kt/bootstrap/")
        google()
        gradlePluginPortal()
        mavenCentral()
    }
}

dependencyResolutionManagement {
    repositories {
        maven("https://packages.jetbrains.team/maven/p/kt/bootstrap/")
        google()
        mavenCentral()
    }
}

include(":shared")
include(":sharedObjc")

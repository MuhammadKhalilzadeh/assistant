buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Force AGP version for buildscript classpath
        classpath("com.android.tools.build:gradle:8.7.0")
    }
}

allprojects {
    repositories {
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/central") }
        google()
        mavenCentral()
    }

    // Force all buildscript classpaths to use the same AGP version
    buildscript {
        configurations.all {
            resolutionStrategy {
                force("com.android.tools.build:gradle:8.7.0")
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
    
    // Ensure consistent JVM targeting for all subprojects
    subprojects {
        afterEvaluate {
            project.extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_11
                    targetCompatibility = JavaVersion.VERSION_11
                }
            }
            
            project.extensions.findByType<org.jetbrains.kotlin.gradle.dsl.KotlinJvmOptions>()?.apply {
                jvmTarget = "11"
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
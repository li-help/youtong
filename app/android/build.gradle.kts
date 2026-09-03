// 阿里云镜像仅用于本地网络环境；CI（GitHub Actions 等）海外网络访问镜像不稳定，
// 会导致依赖下载失败（assembleRelease 报 error while downloading artifacts），CI 上直接走官方仓库。
// 本地如需强制走官方仓库，可设环境变量 ALIYUN_MIRROR=false。
val useAliyunMirror: Boolean =
    System.getenv("ALIYUN_MIRROR")?.let { it != "false" }
        ?: !java.lang.Boolean.parseBoolean(System.getenv("CI"))

allprojects {
    repositories {
        if (useAliyunMirror) {
            maven { url = uri("https://maven.aliyun.com/repository/google") }
            maven { url = uri("https://maven.aliyun.com/repository/public") }
            maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
        }
        google()
        mavenCentral()
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

// file_picker 依赖的 flutter_plugin_android_lifecycle 要求 compileSdk >= 36，
// 但插件子项目默认使用 flutter.compileSdkVersion(34)，这里在项目评估完成后统一提升到 36。
subprojects {
    val raiseCompileSdk: (Project) -> Unit = { p ->
        val ext = p.extensions.findByName("android")
        if (ext is com.android.build.api.dsl.LibraryExtension) {
            val current = ext.compileSdk
            if (current != null && current < 36) {
                ext.compileSdk = 36
            }
        }
    }
    if (project.state.executed) {
        raiseCompileSdk(project)
    } else {
        afterEvaluate { raiseCompileSdk(project) }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

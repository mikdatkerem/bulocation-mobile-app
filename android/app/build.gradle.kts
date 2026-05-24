import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
val isReleaseTask = gradle.startParameter.taskNames.any {
    it.contains("Release", ignoreCase = true)
}

fun requireKeystoreProperty(name: String): String {
    val value = keystoreProperties[name]?.toString()?.trim().orEmpty()
    if (value.isBlank() || value == "change-me") {
        throw GradleException(
            "Release signing property '$name' is missing or still uses the placeholder value. " +
                "Update android/key.properties before building release."
        )
    }
    return value
}

android {
    namespace = "com.bulocation.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.bulocation.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = requireKeystoreProperty("keyAlias")
                keyPassword = requireKeystoreProperty("keyPassword")
                storeFile = file(requireKeystoreProperty("storeFile"))
                storePassword = requireKeystoreProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
                val configuredStoreFile = signingConfig?.storeFile
                if (isReleaseTask && (configuredStoreFile == null || !configuredStoreFile.exists())) {
                    throw GradleException(
                        "Release keystore file not found: ${configuredStoreFile?.absolutePath}. " +
                            "Create it with keytool or update android/key.properties storeFile."
                    )
                }
            } else if (isReleaseTask) {
                throw GradleException(
                    "Release signing is not configured. Create android/key.properties from key.properties.example."
                )
            }
        }
    }
}

flutter {
    source = "../.."
}

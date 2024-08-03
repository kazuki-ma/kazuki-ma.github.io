plugins {
    id("org.jetbrains.kotlin.jvm") version "2.0.0"
    id("org.gradle.java-library")
    id("org.springframework.boot") version "3.3.0"
}

apply(plugin = "io.spring.dependency-management")

repositories {
    jcenter()
}

tasks {
    test {
        useJUnitPlatform()
    }
}

the<io.spring.gradle.dependencymanagement.dsl.DependencyManagementExtension>().apply {
    imports {
        mavenBom(org.springframework.boot.gradle.plugin.SpringBootPlugin.BOM_COORDINATES)
    }
}


dependencies {
    api("com.fasterxml.jackson.core:jackson-annotations")
    api("com.fasterxml.jackson.core:jackson-core")
    api("com.fasterxml.jackson.core:jackson-databind")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    implementation("io.github.microutils:kotlin-logging:1.8.3")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation(platform("org.jetbrains.kotlin:kotlin-bom"))

    testApi("com.fasterxml.jackson.core:jackson-annotations")
    testApi("com.fasterxml.jackson.core:jackson-core")
    testApi("com.fasterxml.jackson.core:jackson-databind")
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit")
}


tasks.withType(JavaCompile::class.java) {
    sourceCompatibility = JavaVersion.VERSION_11.toString()
    targetCompatibility = JavaVersion.VERSION_11.toString()

    options.encoding = "UTF-8"
    options.compilerArgs.addAll(
        listOf(
            "-Xlint:all", "-Xlint:-processing", "-Xlint:-classfile",
            "-Xlint:-serial", "-Xdiags:verbose", // For lint.
            "-parameters" // For Jackson, MyBatis etc.
        )
    )

    if (properties["skip_error"] != "true") {
        // To skip -Werror, invoke gradle with -Pskip_werror=true
        options.compilerArgs.add("-Werror")
    }

    sourceSets {
        main { java { setSrcDirs(srcDirs + file("src/main/kotlin/")) } }
        test { java { setSrcDirs(srcDirs + file("src/test/kotlin/")) } }
    }
}

tasks {
    fun org.jetbrains.kotlin.gradle.dsl.KotlinJvmOptions.setUp() {
        jvmTarget = "11"
        allWarningsAsErrors = true
        javaParameters = true
        freeCompilerArgs = listOf(
            "-Xjsr305=strict",
            "-Xemit-jvm-type-annotations",
            "-Xopt-in=kotlin.ExperimentalStdlibApi",
            "-Xopt-in=kotlin.RequiresOptIn",
            "-Xinline-classes"
        )
    }

    compileKotlin {
        kotlinOptions {
            setUp()
        }
    }
    compileTestKotlin {
        kotlinOptions {
            setUp()
        }
    }
}

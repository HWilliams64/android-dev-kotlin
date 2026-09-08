# Kotlin command-line dependency

Use **[install-kotlin.sh](install-kotlin.sh)** to add Kotlin 2.2.21 to a
Grader Than **Java workspace**. It installs `kotlin` and `kotlinc` only.
It does not install a Jupyter kernel, Python packages, or IDE extensions.

1. Create a Grader Than dependency and paste the entire script into its script field.
2. Attach the dependency to your Java workspace configuration.
3. Start or restart that workspace. The dependency runs as root during setup.

For a manual installation inside the Java workspace:

```bash
sudo bash install-kotlin.sh
```

Omit `sudo` if the terminal already runs as root. The script requires an existing
Java 17+ JDK, Bash, curl, unzip, sha256sum, and flock. The tested Java workspace
already supplies them. Internet access to GitHub release downloads is required
on the first run. No shell activation is needed.

## Run Kotlin

In the workspace terminal:

```bash
kotlin -version
kotlinc -version
```

Save a file named `hello.kt`:

```kotlin
fun main() {
    println("Hello, Kotlin!")
}
```

Compile it and run the resulting Java archive:

```bash
kotlinc hello.kt -include-runtime -d hello.jar
java -jar hello.jar
```

Alternatively, save `println("Hello, Kotlin!")` in `hello.kts` and run:

```bash
kotlinc -script hello.kts
```

## Installation and verification

The script downloads the official compiler archive and checks its pinned SHA-256
digest before extracting it. Files go under
`/opt/graderthan/kotlin-compiler-2.2.21`; links in `/usr/local/bin` expose the two
commands to workspace users. Repeat runs reuse this installation. Conflicting
commands or unrecognized existing installations cause a clear failure instead
of being overwritten. Install this dependency on a fresh Java workspace if a
different Kotlin dependency already manages those paths.

Tested on the local Grader Than Java base image `vd1298cb` (image ID
`b58f34f45dd5`, Linux amd64, Java 21.0.7). A fresh container was bootstrapped
using `gt_env_install test`; the IDE was started as the workspace user.
Installation through `gt_clean_env` took 5.8 seconds and a repeat took 4.1 seconds,
both within the dependency runner's 120-second timeout. Network speeds vary.

The installer now runs its two final command checks concurrently and waits for
both to succeed. In five alternating repeat runs per version on the same local
Java image, the median decreased from **2.88 seconds to 2.70 seconds** (about 6%).
The updated fresh installation took **3.96 seconds** in that test. These are
local measurements, not guaranteed startup times. Downloading, verifying the
checksum, and extracting the archive still happen in order. Failure tests
confirmed that either command failing rejects installation and that the other
validation worker finishes before the script exits.

Checks passed for Bash syntax, ShellCheck, compilation, `.kts` execution, the
`kotlin` launcher, calling Java from Kotlin, and execution as UID 1000. Java's
executable checksum and the Jupyter kernel definitions were unchanged. Non-root
installation and conflicting command paths were rejected. Other image versions
and ARM64 were not tested.

The test container was removed afterward. The pre-existing shared Java base
image and other workspaces were preserved; no derived image was built.

Sources: [official Kotlin compiler instructions](https://kotlinlang.org/docs/command-line.html),
[pinned Kotlin 2.2.21 release](https://github.com/JetBrains/kotlin/releases/tag/v2.2.21).

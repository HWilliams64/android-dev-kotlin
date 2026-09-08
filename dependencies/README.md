# Kotlin notebooks and scripts in Grader Than Workspace

Use [install-kotlin-kernel.sh](install-kotlin-kernel.sh) as a workspace dependency
script for the **Java workspace**. It installs the official Kotlin Jupyter
kernel and makes it available to the workspace's existing VS Code Jupyter
extension. It also installs the standalone Kotlin compiler and Code Runner so
students can run `.kts` files with the editor's play button.

The script also installs the small **Kotlin Language** extension. This registers
Kotlin as a VS Code cell language; kernel installation alone was insufficient
for the workspace IDE to execute Kotlin cells.

## Add the dependency

1. Create a dependency in Grader Than and paste the **entire contents** of
   `install-kotlin-kernel.sh` into its shell-script field.
2. Attach that dependency to the course's Java workspace configuration.
3. Start or restart the workspace so dependency installation runs before the IDE
   opens. The dependency runner executes the script as root.

To install manually inside an existing compatible workspace, run:

```bash
sudo bash install-kotlin-kernel.sh
```

If the terminal already runs as root, omit `sudo`. Do not run this installer on
your personal computer; it targets the Grader Than Java workspace.

## Open a Kotlin notebook

Open or create an `.ipynb` file in the workspace's VS Code IDE. Use **Select
Kernel** and choose the **Kotlin** Jupyter kernel. If necessary, open **Select
Another Kernel → Jupyter Kernel** first. Reload the IDE window if you installed
the dependency while the IDE was already open.

Run this in a code cell:

```kotlin
val course = "CSC-244"
println("Kotlin is ready for $course")
```

For notebooks created programmatically, use:

```json
{
  "kernelspec": {
    "name": "kotlin",
    "display_name": "Kotlin",
    "language": "kotlin"
  },
  "language_info": {"name": "kotlin", "file_extension": ".kt"}
}
```

Code cells can use `metadata.vscode.languageId: "kotlin"`. This kernel runs
ordinary Kotlin/JVM code. Android applications still require Android Studio.

## Run a Kotlin script

Save your code in a file ending in `.kts`, such as `demo.kts`. Click **Run Code**
(the play button at the top right of the editor). Code Runner uses its standard
`kotlinc -script` command and shows the result in its **Output** panel. Save edits
before running. No notebook kernel selection is needed for a script.

You can run the same script from the terminal:

```bash
kotlinc -script demo.kts
```

The two file types use different runners: `.ipynb` cells use the Kotlin Jupyter
kernel; `.kts` files use the command-line compiler. The dependency does not add a
Python helper or change Code Runner's executor settings. If you already added an
older version of this dependency, replace its script with the current contents
and restart the workspace to install the compiler and Run Code extension too.

## Installation details

- Pinned kernel: `kotlin-jupyter-kernel==0.19.0.944`, downloaded from PyPI and
  verified against its SHA-256 digest.
- Java: requires Java 17 or newer on `PATH` and reuses it. Java is never
  installed or upgraded; no `apt` commands run. The tested Java image has Java 21.
- Kotlin environment: `/opt/graderthan/kotlin-jupyter`, inheriting the existing
  Jupyter packages without upgrading or replacing them.
- Registered kernel: `/usr/local/share/jupyter/kernels/kotlin`. Absolute Python
  and Java paths allow discovery and execution without shell activation.
- Language extension: `mathiasfrohlich.Kotlin@1.7.1`, installed from a pinned,
  SHA-256-verified Open VSX package. It adds Kotlin syntax support without a
  separate language-server process.
- Script compiler: Kotlin 2.2.21, from the official SHA-256-verified archive,
  installed under `/opt/graderthan/kotlin-compiler-2.2.21`. `kotlin` and `kotlinc`
  are linked into `/usr/local/bin`, so shell activation is unnecessary.
- Run Code extension: `formulahendry.code-runner@0.12.2`, installed from a pinned,
  SHA-256-verified Open VSX package. Its default `.kts` runner is `kotlinc -script`.
- The kernel, compiler, and extension installation jobs run concurrently.
  All must finish successfully before the dependency reports success.
- Repeated installation is supported. Failed commands return a nonzero status
  to the dependency runner.
- Internet access is required on first installation for the Kotlin wheel,
  compiler archive, and extensions. No API key is needed.

In the earlier kernel-only Java workspace test, the first install took **16.2 seconds**, compared
with **21.4 seconds** for the original script on the same image (about 24% faster).
A repeat took **1.9 seconds**. These times exclude workspace startup and vary
with network speed and host load. Actual VS Code kernel selection, notebook
execution, and saved output were verified as the workspace user.

The current compiler, Run Code, and notebook verification is recorded in
[the script parity report](../../.evidence/kotlin-script-parity/REVIEW.md).
The earlier kernel-only Java workspace validation is recorded in
[the installation and VS Code test report](../../.evidence/kotlin-java-workspace/REVIEW.md).

Sources: [Kotlin script execution](https://kotlinlang.org/docs/command-line.html#run-scripts),
[official Kotlin Jupyter installation and usage](https://github.com/Kotlin/kotlin-jupyter),
[pinned PyPI release](https://pypi.org/project/kotlin-jupyter-kernel/0.19.0.944/),
[Kotlin Language extension](https://github.com/mathiasfrohlich/vscode-kotlin).

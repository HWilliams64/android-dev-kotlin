#!/usr/bin/env bash
# Grader Than Java workspace dependency. Run as root during workspace setup.
# Requires existing Java 17+; never installs Java or runs apt.
# Adds the Kotlin compiler and Jupyter kernel without replacing existing Jupyter.
set -Eeuo pipefail
umask 022

readonly kernel_version='0.19.0.944'
readonly kernel_wheel='https://files.pythonhosted.org/packages/cf/bc/2cd20bddab3e790b1307379bd91a15a405f241646b4122329c59dd55d867/kotlin_jupyter_kernel-0.19.0.944-py3-none-any.whl'
readonly kernel_sha256='dc654a426a28e6621aeb0bd7772d268a9a877aabae4a17b73383752a416281a3'
readonly install_dir='/opt/graderthan/kotlin-jupyter'
readonly kernel_prefix='/usr/local'
readonly language_version='1.7.1'
readonly language_url='https://open-vsx.org/api/mathiasfrohlich/Kotlin/1.7.1/file/mathiasfrohlich.Kotlin-1.7.1.vsix'
readonly language_sha256='23bbabe7265168a60c0825c4025589e510fad6b41b2b5bc55fc3e1936ec9e20c'
readonly compiler_version='2.2.21'
readonly compiler_url="https://github.com/JetBrains/kotlin/releases/download/v${compiler_version}/kotlin-compiler-${compiler_version}.zip"
readonly compiler_sha256='a623871f1cd9c938946948b70ef9170879f0758043885bbd30c32f024e511714'
readonly compiler_dir="/opt/graderthan/kotlin-compiler-${compiler_version}"
readonly runner_version='0.12.2'
readonly runner_url='https://open-vsx.org/api/formulahendry/code-runner/0.12.2/file/formulahendry.code-runner-0.12.2.vsix'
readonly runner_sha256='99246afaaff6bedec962976ea2cdd07e70ddd58b840666fdcf67fe21e3513dbe'

fail() { printf 'Kotlin kernel installation failed: %s\n' "$*" >&2; exit 1; }
trap 'printf "Kotlin kernel installation stopped at line %s.\n" "$LINENO" >&2' ERR

[[ $EUID -eq 0 ]] || fail 'Run this as a Grader Than dependency script (root), or with sudo.'
command -v python3 >/dev/null || fail 'The workspace must already provide Python 3 and Jupyter.'
command -v gt-ide >/dev/null || fail 'Use the Grader Than workspace with its VS Code IDE installed.'
base_python="$(command -v python3)"
readonly base_python
"$base_python" -c 'import jupyter_client, jupyter_core' || fail 'Use the Grader Than base workspace with Jupyter installed.'

# Dependency layers can be retried. Serialize retries without locking other tools.
mkdir -p /opt/graderthan
exec 9>/opt/graderthan/.kotlin-jupyter-install.lock
flock -w 90 9 || fail 'Another Kotlin installation is still running.'

# Prefer the existing Java runtime. Pin the selected path in the kernelspec so
# VS Code does not need shell activation or a global JAVA_HOME change.
java_home=''
if command -v java >/dev/null 2>&1; then
    java_bin="$(readlink -f "$(command -v java)")"
    java_major="$("$java_bin" -version 2>&1 | sed -n '1s/.*version "\([0-9]*\).*/\1/p')"
    if [[ $java_major =~ ^[0-9]+$ ]] && (( java_major >= 17 )); then
        java_home="$(dirname "$(dirname "$java_bin")")"
    fi
fi
[[ -n $java_home ]] || fail 'Use a Java workspace with Java 17 or newer on PATH; this dependency does not install Java.'
[[ -x "$java_home/bin/java" ]] || fail 'The selected Java runtime is unavailable.'

install_kernel() {
    local installed_version
    # Inherit the platform's Jupyter packages but keep Kotlin's Python launcher
    # isolated. The versioned wheel bundles the Kotlin compiler and runtime JARs.
    if [[ ! -x "$install_dir/bin/python" ]]; then
        "$base_python" -m venv --system-site-packages "$install_dir"
    fi
    "$install_dir/bin/python" -c 'import jupyter_client, jupyter_core' || fail 'The Kotlin environment cannot access the workspace Jupyter installation.'
    installed_version="$("$install_dir/bin/python" -c 'from importlib.metadata import version, PackageNotFoundError
try: print(version("kotlin-jupyter-kernel"))
except PackageNotFoundError: print("")')"
    if [[ $installed_version != "$kernel_version" || ! -f "$install_dir/share/jupyter/kernels/kotlin/kernel.json" ]]; then
        printf 'Installing Kotlin Jupyter %s (verified wheel)...\n' "$kernel_version"
        printf '%s --hash=sha256:%s\n' "$kernel_wheel" "$kernel_sha256" |
            "$install_dir/bin/python" -m pip install --disable-pip-version-check \
                --no-deps --ignore-installed --require-hashes --timeout 25 --retries 2 -r /dev/stdin
    fi

    # The upstream wheel uses a bare "python" launcher. Make both launch commands
    # absolute and register under /usr/local/share/jupyter/kernels for every
    # workspace user, rather than accidentally registering under /root.
    "$install_dir/bin/python" - "$java_home" "$kernel_prefix" <<'PY'
import json
from pathlib import Path
import sys
import tempfile
from jupyter_client.kernelspec import KernelSpecManager

java_home, prefix = sys.argv[1:]
source = Path(sys.prefix) / "share/jupyter/kernels/kotlin"
spec = json.loads((source / "kernel.json").read_text())
spec["argv"][0] = sys.executable
spec["metadata"]["jar_path_detect_command"][0] = sys.executable
spec.setdefault("env", {})["KOTLIN_JUPYTER_JAVA_HOME"] = java_home
(source / "kernel.json").write_text(json.dumps(spec, indent=2) + "\n")
with tempfile.TemporaryDirectory(prefix="kotlin-kernelspec-") as temporary:
    import shutil
    staging = Path(temporary) / "kotlin"
    shutil.copytree(source, staging)
    (staging / "kernel.json").write_text(json.dumps(spec, indent=2) + "\n")
    destination = KernelSpecManager().install_kernel_spec(
        str(staging), kernel_name="kotlin", prefix=prefix, replace=True
    )
registered = KernelSpecManager().get_kernel_spec("kotlin")
assert registered.language == "kotlin", "Unexpected registered kernel language"
assert registered.argv[0] == sys.executable, "Unexpected registered Python launcher"
assert registered.env["KOTLIN_JUPYTER_JAVA_HOME"] == java_home
print(f"Registered Kotlin kernel: {destination}")
PY

}

install_compiler() (
    local compiler_temp launcher
    compiler_temp="$(mktemp -d /opt/graderthan/.kotlin-compiler.XXXXXXXX)"
    trap 'rm -rf -- "$compiler_temp"' EXIT
    for launcher in kotlin kotlinc; do
        if [[ -e /usr/local/bin/$launcher || -L /usr/local/bin/$launcher ]]; then
            [[ $(readlink "/usr/local/bin/$launcher") == "$compiler_dir/bin/$launcher" ]] ||
                fail "An unrelated /usr/local/bin/$launcher already exists; it was not replaced."
        fi
    done
    if [[ ! -x "$compiler_dir/bin/kotlinc" ]]; then
        printf 'Installing Kotlin compiler %s (verified archive)...\n' "$compiler_version"
        curl --fail --location --silent --show-error --retry 2 --connect-timeout 15 \
            --max-time 120 "$compiler_url" -o "$compiler_temp/compiler.zip"
        printf '%s  %s\n' "$compiler_sha256" "$compiler_temp/compiler.zip" | sha256sum --check --status
        "$base_python" - "$compiler_temp" <<'PY'
from pathlib import Path
import sys
import zipfile
root = Path(sys.argv[1])
with zipfile.ZipFile(root / "compiler.zip") as archive:
    archive.extractall(root)
for launcher in (root / "kotlinc/bin").iterdir():
    if launcher.is_file() and launcher.suffix != ".bat":
        launcher.chmod(0o755)
PY
        mv "$compiler_temp/kotlinc" "$compiler_dir"
    fi
    mkdir -p /usr/local/bin
    for launcher in kotlin kotlinc; do
        ln -sfn "$compiler_dir/bin/$launcher" "/usr/local/bin/$launcher"
    done
    /usr/local/bin/kotlinc -version
)

install_language() {
    local workspace_user workspace_home extension_dir language_manifest runner_manifest
    # VS Code also needs a registered Kotlin cell language. Without this lightweight
    # syntax extension it can discover/start the kernel but refuse to execute cells.
    workspace_user="${USERNAME:-developer}"
    workspace_home="$(getent passwd "$workspace_user" | cut -d: -f6)"
    [[ $workspace_home == /* ]] || fail 'Cannot locate the workspace user home.'
    extension_dir="$workspace_home/.ide/extensions"
    chmod 755 "$extension_temp"
    mkdir "$extension_temp/ide"
    chown "$workspace_user:$(id -gn "$workspace_user")" "$extension_temp/ide"
    language_manifest="$extension_dir/mathiasfrohlich.kotlin-$language_version/package.json"
    if [[ ! -f $language_manifest ]]; then
        curl --fail --location --silent --show-error --retry 2 --connect-timeout 15 \
            --max-time 45 "$language_url" -o "$extension_temp/kotlin.vsix"
        printf '%s  %s\n' "$language_sha256" "$extension_temp/kotlin.vsix" | sha256sum --check --status
        # The IDE CLI runs as the workspace user so its extension index stays writable.
        runuser -u "$workspace_user" -- env "HOME=$workspace_home" gt-ide \
            --extensions-dir "$extension_dir" --user-data-dir "$extension_temp/ide" \
            --install-extension "$extension_temp/kotlin.vsix"
    fi
    "$base_python" - "$language_manifest" "$language_version" <<'PY'
import json
import sys
from pathlib import Path
manifest = json.loads(Path(sys.argv[1]).read_text())
assert manifest["version"] == sys.argv[2], "Unexpected Kotlin language extension version"
assert any(language["id"] == "kotlin" for language in manifest["contributes"]["languages"])
PY

    # The Java image has no generic Run Code button for Kotlin. Install the
    # standard extension for students too; its unchanged .kts default is kotlinc -script.
    runner_manifest="$extension_dir/formulahendry.code-runner-$runner_version/package.json"
    if [[ ! -f $runner_manifest ]]; then
        curl --fail --location --silent --show-error --retry 2 --connect-timeout 15 \
            --max-time 45 "$runner_url" -o "$extension_temp/code-runner.vsix"
        printf '%s  %s\n' "$runner_sha256" "$extension_temp/code-runner.vsix" | sha256sum --check --status
        runuser -u "$workspace_user" -- env "HOME=$workspace_home" gt-ide \
            --extensions-dir "$extension_dir" --user-data-dir "$extension_temp/ide" \
            --install-extension "$extension_temp/code-runner.vsix"
    fi
    "$base_python" - "$runner_manifest" "$runner_version" <<'PY'
import json
from pathlib import Path
import sys
manifest = json.loads(Path(sys.argv[1]).read_text())
assert manifest["version"] == sys.argv[2], "Unexpected Code Runner extension version"
properties = manifest["contributes"]["configuration"]["properties"]
assert properties["code-runner.executorMapByFileExtension"]["default"][".kts"] == "kotlinc -script"
PY

}

# These installers write separate locations. Keep the retry lock until both
# finish, and propagate either failure instead of reporting partial success.
# Wait during cleanup too, so temporary files are never removed under a worker.
extension_temp="$(mktemp -d /tmp/kotlin-language.XXXXXXXX)"
worker_pids=()
cleanup() {
    local pid
    for pid in "${worker_pids[@]}"; do
        wait "$pid" 2>/dev/null || true
    done
    rm -rf -- "$extension_temp"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

install_kernel &
worker_pids+=("$!")
install_language &
worker_pids+=("$!")
install_compiler &
worker_pids+=("$!")
install_status=0
for pid in "${worker_pids[@]}"; do
    if wait "$pid"; then
        :
    else
        install_status=$?
    fi
done
worker_pids=()
[[ $install_status -eq 0 ]] || fail 'A Kotlin installer failed; see the error above. Rerun the dependency to retry.'

printf 'Kotlin compiler %s and Jupyter kernel %s are installed.\n' "$compiler_version" "$kernel_version"
printf 'For .kts files use Run Code (kotlinc -script). For notebooks select the Kotlin Jupyter kernel.\n'

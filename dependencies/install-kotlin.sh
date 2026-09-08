#!/usr/bin/env bash
# Grader Than Java workspace dependency: Kotlin/JVM command-line tools only.
# Paste this entire script into the dependency's script field. Runs as root.
set -Eeuo pipefail
umask 022

readonly kotlin_version='2.2.21'
readonly archive_sha256='a623871f1cd9c938946948b70ef9170879f0758043885bbd30c32f024e511714'
readonly archive_url="https://github.com/JetBrains/kotlin/releases/download/v${kotlin_version}/kotlin-compiler-${kotlin_version}.zip"
readonly install_dir="/opt/graderthan/kotlin-compiler-${kotlin_version}"

fail() { printf 'Kotlin installation failed: %s\n' "$*" >&2; exit 1; }
trap 'printf "Kotlin installation stopped at line %s.\n" "$LINENO" >&2' ERR
[[ $EUID -eq 0 ]] || fail 'Run as a workspace dependency or use sudo bash install-kotlin.sh.'
for tool in java javac curl unzip sha256sum flock; do
    command -v "$tool" >/dev/null || fail "Missing $tool. Use the Grader Than Java workspace."
done
java_properties="$(java -XshowSettings:properties -version 2>&1)"
java_major="$(awk '/java.specification.version =/ {print $3}' <<< "$java_properties")"
if [[ ! $java_major =~ ^[0-9]+$ ]] || (( java_major < 17 )); then
    fail 'The existing Java runtime must be Java 17 or newer.'
fi

# Serialize retries. No shell profile, Java, Python, Jupyter, or IDE changes.
mkdir -p /opt/graderthan /usr/local/bin
exec 9>/opt/graderthan/.kotlin-compiler-install.lock
flock -w 5 9 || fail 'Another Kotlin compiler installation is running; retry later.'
for launcher in kotlin kotlinc; do
    if [[ -e /usr/local/bin/$launcher || -L /usr/local/bin/$launcher ]]; then
        [[ $(readlink "/usr/local/bin/$launcher") == "$install_dir/bin/$launcher" ]] ||
            fail "An unrelated /usr/local/bin/$launcher exists; it was not replaced."
    fi
done

temporary_dir=''
validation_pids=()
cleanup() {
    # Reap validation workers on interruption before releasing the install lock.
    local pid
    for pid in "${validation_pids[@]}"; do
        kill "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
    done
    if [[ -n $temporary_dir ]]; then rm -rf -- "$temporary_dir"; fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

if [[ -e $install_dir ]]; then
    # Never overwrite a different or partial installation silently.
    if [[ ! -f $install_dir/.archive-sha256 ]] ||
        [[ $(cat "$install_dir/.archive-sha256") != "$archive_sha256" ]]; then
        fail "Unrecognized installation at $install_dir; inspect it before retrying."
    fi
else
    temporary_dir="$(mktemp -d /opt/graderthan/.kotlin-cli.XXXXXXXX)"
    printf 'Downloading Kotlin %s...\n' "$kotlin_version"
    curl --fail --location --silent --show-error --proto '=https' --proto-redir '=https' \
        --connect-timeout 10 --max-time 45 --retry 1 --retry-max-time 90 \
        "$archive_url" -o "$temporary_dir/compiler.zip"
    printf '%s  %s\n' "$archive_sha256" "$temporary_dir/compiler.zip" | sha256sum --check --status
    unzip -q "$temporary_dir/compiler.zip" -d "$temporary_dir"
    [[ -x $temporary_dir/kotlinc/bin/kotlinc && -x $temporary_dir/kotlinc/bin/kotlin ]] ||
        fail 'Compiler archive is missing its executable launchers.'
    chmod -R a+rX "$temporary_dir/kotlinc"
    printf '%s\n' "$archive_sha256" > "$temporary_dir/kotlinc/.archive-sha256"
    # Same filesystem: publish only the fully extracted, verified installation.
    mv "$temporary_dir/kotlinc" "$install_dir"
fi

# These independent JVM checks can run together. Both must succeed before the
# command links are published; wait for both even if one reports a failure.
"$install_dir/bin/kotlinc" -version &
validation_pids+=("$!")
"$install_dir/bin/kotlin" -version &
validation_pids+=("$!")
validation_status=0
for pid in "${validation_pids[@]}"; do
    if wait "$pid"; then
        :
    else
        validation_status=$?
    fi
done
validation_pids=()
[[ $validation_status -eq 0 ]] || fail 'A Kotlin command failed validation; see the error above.'
for launcher in kotlin kotlinc; do
    ln -sfn "$install_dir/bin/$launcher" "/usr/local/bin/$launcher"
done
printf 'Kotlin %s ready: kotlin and kotlinc are available on PATH.\n' "$kotlin_version"

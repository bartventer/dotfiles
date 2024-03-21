#!/bin/sh

# run_sudo_cmd Run commands with sudo in a way that works both locally and in CI.
# It also ensures that dnf check-update does not cause the script to exit when using set -e.
# Usage: run_sudo_cmd "command"
run_sudo_cmd() {
    run_cmd() {
        if [ "$1" = "dnf check-update"* ]; then
            # dnf check-update returns a non-zero exit code when updates are available.
            # This is expected behavior and not an error. However, it can cause issues
            # if you're using set -e or set -o errexit in your script, which cause the
            # script to exit when any command returns a non-zero exit code. To handle this,
            # we ignore the exit code of dnf check-update.
            eval "$1" || true
        else
            eval "$1"
        fi
    }

    if [ "$CI" = "true" ]; then
        run_cmd "$1"
    else
        if command -v bash >/dev/null 2>&1; then
            sudo -E bash -c "run_cmd() { if [ \"\$1\" = \"dnf check-update\"* ]; then eval \"\$1\" || true; else eval \"\$1\"; fi; }; declare -f run_cmd > /dev/null; run_cmd '$1'"
        else
            sudo -E sh -c "run_cmd() { if [ \"\$1\" = \"dnf check-update\"* ]; then eval \"\$1\" || true; else eval \"\$1\"; fi; }; declare -f run_cmd > /dev/null; run_cmd '$1'"
        fi
    fi
}
# detect_distro Detects the OS and returns the distro name. The distro name is
# lowercased, e.g., "macos", "arch", "debian", "ubuntu", "fedora", "rhel", or "
# unknown".
# Usage: detect_distro
detect_distro() {
    distro=""
    case "$OSTYPE" in
      darwin*) distro="macos" ;; 
      *)
        if [ -f "/etc/os-release" ]; then
            distro=$(awk -F= '/^NAME/{print tolower($2)}' /etc/os-release | tr -d '"' | awk '{print $1}')
        fi
        ;;
    esac
    echo "$distro"
}

# debug_system Prints system information for debugging purposes. It prints the
# current date, user, current directory, environment variables, and the contents
# of /etc/os-release and /etc/lsb-release. On macOS, it also prints the macOS
# version and detailed software information.
debug_system() {
    files="/etc/os-release /etc/lsb-release"
    hyphens=$(printf '%*s' 80 | tr ' ' '-')

    printf "\n\033[1;35m[DEBUG]\033[0m\n"
    echo "$hyphens"
    echo "Date: $(TZ=UTC date +"%Y-%m-%d %H:%M:%S")"
    echo "User: $(whoami)"
    echo "Current directory: $(pwd)"
    echo "$hyphens"
    echo "Environment variables:"
    printenv | sed 's/^/    /'
    echo "$hyphens"

    for file in $files; do
        if [ -f "$file" ]; then
            echo "Contents of $file:"
            cat "$file" | sed 's/^/    /'
            echo "$hyphens"
        fi
    done

    os=$(detect_distro)
    if [ "$os" = "macos" ]; then
        echo "macOS version:"
        sw_vers
        echo "$hyphens"
        echo "Detailed software information:"
        system_profiler SPSoftwareDataType
        echo "$hyphens"
    fi
}
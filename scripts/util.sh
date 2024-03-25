#!/bin/bash
set -e

# run_cmd Run commands in a way that works both locally and in CI.
# It also ensures that dnf check-update does not cause the script to exit when using set -e.
# Usage: run_cmd "command"
run_cmd() {
    if [ "$1" = "dnf check-update -y" ]; then
        eval "$1" || true
    else
        eval "$1"
    fi
}

# run_sudo_cmd Run commands with sudo.
# Usage: run_sudo_cmd "command"
run_sudo_cmd() {
    echo "Running command with sudo: $1"
    if [ "$CI" = "true" ]; then
        run_cmd "$1"
    else
        sudo -E bash -c "$(declare -f run_cmd); run_cmd '$1'"
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
    echo "CI: $CI"
    set +e
    echo "Kernel: $(uname -s)"
    set -e
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

#!/bin/bash

set -e

SCRIPT_DIR="$(dirname "$1")"
if [[ ! -d "$SCRIPT_DIR" ]]; then
    echo "Error: SCRIPT_DIR ($SCRIPT_DIR) does not exist."
    exit 1
fi

LOG_SCRIPT="$SCRIPT_DIR/log.sh"
if [[ ! -f "$LOG_SCRIPT" ]]; then
    echo "Error: log.sh script ($LOG_SCRIPT) not found."
    exit 1
fi
# shellcheck disable=SC1091
# shellcheck source=scripts/log.sh
. "$SCRIPT_DIR/log.sh"

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
# Usage: run_sudo_cmd "command" "sudo_flags"
run_sudo_cmd() {
    local cmd=${1//$'\n'/ }
    local sudo_flags=${2:-}
    echo ":: Running command with sudo: $cmd"
    if [ "$CI" = "true" ]; then
        run_cmd "$cmd"
    else
        if [ -z "$sudo_flags" ]; then
            sudo -E env "PATH=$PATH" bash -c "$(declare -f run_cmd); run_cmd '$cmd'"
        else
            # shellcheck disable=SC2086
            sudo $sudo_flags -E env "PATH=$PATH" bash -c "$(declare -f run_cmd); run_cmd '$cmd'"
        fi
    fi
}

# detect_distro Detects the OS and returns the distro name. The distro name is
# lowercased, e.g., "macos", "arch", "debian", "ubuntu", "fedora", "rhel", or "
# unknown".
# Usage: detect_distro
detect_distro() {
    distro=""
    # case "$OSTYPE" in
    case "$(uname -s)" in
    Darwin) distro="macos" ;;
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
    local files="/etc/os-release /etc/lsb-release"
    local hyphens
    hyphens=$(printf '%*s' 80 '' | tr ' ' '=')
    # shellcheck disable=SC2155
    local is_terminal=$(tput colors 2>/dev/null)
    local color_purple=""
    local color_orange=""
    local color_none="" # No Color
    if [ -n "$is_terminal" ]; then
        color_purple=$(tput setaf 5) # Purple
        color_orange=$(tput setaf 3) # Orange
        color_none=$(tput sgr0)      # Reset
    fi

    cat <<EOF

${color_purple}[DEBUG]${color_none}
${hyphens}
Date: $(TZ=UTC date +"%Y-%m-%d %H:%M:%S")
User: $(whoami)
Kernel: $(uname -s)
Current directory: $(pwd)
${hyphens}
Environment variables:
$(printenv | sed 's/^/    /')
${hyphens}
EOF

    for file in $files; do
        if [ -f "$file" ]; then
            cat <<EOF
${color_orange}Contents of ${file}:${color_none}
$(sed 's/^/    /' <"${file}")
${hyphens}
EOF
        fi
    done

    os=$(detect_distro)
    if [ "$os" = "macos" ]; then
        cat <<EOF
${color_orange}macOS information:${color_none}
macOS version:
$(sw_vers)
${hyphens}
Detailed software information:
$(system_profiler SPSoftwareDataType)
${hyphens}
EOF
    fi
}

# update_path Prepends directories to the PATH environment variable. Checks if
# the directory is already in the PATH before prepending it to avoid
# duplicates.
# Usage: update_path "dir1" "dir2" ...
update_path() {
    echo "🔍 Checking PATH..."
    for dir in "$@"; do
        case ":$PATH:" in
        *":$dir:"*) echo "✔️ $dir already in PATH" ;;
        *)
            echo "➕ Adding $dir to PATH"
            PATH=$dir:$PATH
            ;;
        esac
    done
    export PATH
    echo "OK. PATH is up to date."
}

# update_zsh_local: This function updates the zsh_local file with the provided line.
# If the line already exists in the file, it will not be added. If the line exists but is commented out, it will be uncommented.
#
# Usage: update_zsh_local "zsh_local" "line_to_add"
#
# Arguments:
#   zsh_local: The path to the zsh_local file. This should be an absolute path.
#   line_to_add: The line to add to the zsh_local file. If this line already exists in the file, it will not be added again.
#
# Outputs:
#   If the zsh_local file does not exist, an error message is printed and the function exits with a status of 1.
#   If the line to add is already in the zsh_local file but commented out, it is uncommented and a message is printed.
#   If the line to add is not in the zsh_local file, it is added and a message is printed.
#   If the zsh_local file is successfully updated, a confirmation message is printed.
#
# Returns:
#   This function does not return a value. It exits with a status of 1 if the zsh_local file does not exist.
update_zsh_local() {
    local zsh_local=$1
    local line_to_add=$2

    if [ ! -f "${zsh_local}" ]; then
        echo "Error: ${zsh_local} does not exist."
        exit 1
    fi

    log_info "Updating ${zsh_local} with ${line_to_add}..."
    # check if the line exists but is commented out, if so uncomment it
    if grep -q "# ${line_to_add}" "${zsh_local}"; then
        echo "Line is commented out. Uncommenting..."
        sed -i "s/# ${line_to_add}/${line_to_add}/" "${zsh_local}"
    # check if the line exists, if not add it
    elif ! grep -q "${line_to_add}" "${zsh_local}"; then
        echo "Line not found. Adding..."
        echo "${line_to_add}" >>"${zsh_local}"
    fi
    echo "OK. ${zsh_local} updated."
}

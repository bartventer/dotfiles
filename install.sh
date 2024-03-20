#!/bin/sh
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Bart Venter.
# Licensed under the MIT License. See https://github.com/bartventer/dotfiles for license information.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/bartventer/dotfiles/tree/main/README.md
# Maintainer: Bart Venter <https://github.com/bartventer>

set -e

# Ensure script is run as root if CI is not true
if [ "$CI" != "true" ]; then
    echo "🔒 Ensuring script is run as root..."
    if [ "$(id -u)" -ne 0 ]; then
        echo "❌ Script must be run as root. Use sudo or su." >&2
        exit 1
    fi
    echo "✅ OK. Script is run as root."
fi

# Detect the OS.
echo "🔍 Detecting OS..."
OS="unknown"
case "$OSTYPE" in
  darwin*) OS="macos" ;; 
  *)
    if [ -f "/etc/os-release" ]; then
      # shellcheck disable=SC1091
      . /etc/os-release
      OS=$ID
    fi
    ;;
esac
echo "✅ OK. Detected OS: $OS"

# Source the run_sudo_cmd function
. scripts/run_sudo_cmd.sh

# Ensure bash is installed
echo "🔧 Ensuring bash is installed..."
if [ "$OS" = "arch" ]; then
    run_sudo_cmd "pacman -Syu bash --noconfirm"
elif [ "$OS" = "debian" ] || [ "$OS" = "ubuntu" ]; then
    run_sudo_cmd "apt-get update -y && apt-get install -y bash"
elif [ "$OS" = "fedora" ]; then
    run_sudo_cmd "dnf check-update -y && dnf install -y bash"
elif [ "$OS" = "rhel" ]; then
    run_sudo_cmd "yum check-update -y && yum install -y bash"
elif [ "$OS" = "macos" ]; then
    run_sudo_cmd "brew update && brew install bash"
else
    echo "OS $OS not supported."
    exit 1
fi
echo "✅ OK. Bash is installed."

# Execute main script
echo "🚀 Executing main script..."
exec /bin/bash "$(dirname "$0")/main.sh" "$@"
exit $?
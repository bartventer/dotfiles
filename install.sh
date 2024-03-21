#!/bin/sh
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Bart Venter.
# Licensed under the MIT License. See https://github.com/bartventer/dotfiles for license information.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/bartventer/dotfiles/tree/main/README.md
# Maintainer: Bart Venter <https://github.com/bartventer>

set -e

# Source the util script.
. scripts/util.sh

debug_system

# Detect the OS.
echo "🔍 Detecting OS..."
OS=$(detect_distro)
echo "✅ OK. Detected OS: $OS"

# Ensure bash is installed
echo "🔧 Ensuring bash is installed..."
case "$OS" in
  arch) run_sudo_cmd "pacman -Syu bash --noconfirm" ;;
  debian|ubuntu) run_sudo_cmd "apt-get update -y && apt-get install -y bash" ;;
  fedora) run_sudo_cmd "dnf check-update -y && dnf install -y bash" ;;
  rhel) run_sudo_cmd "yum check-update -y && yum install -y bash" ;;
  macos) run_sudo_cmd "brew update && brew install bash" ;;
  *)
    echo "OS $OS not supported."
    exit 1
    ;;
esac
echo "✅ OK. Bash is installed."

# Execute main script
echo "🚀 Executing main script (OS:$OS)..."
exec /bin/bash "$(dirname "$0")/main.sh" "$OS" "$@"
exit $?
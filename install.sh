#!/bin/sh
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Bart Venter.
# Licensed under the MIT License. See https://github.com/bartventer/dotfiles for license information.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/bartventer/dotfiles/tree/main/README.md
# Maintainer: Bart Venter <https://github.com/bartventer>
set -e

CI=${CI:-false}
# sudo_if Run commands with sudo if not in CI.
# Usage: sudo_if "command"
sudo_if() {
  if [ "$CI" = "true" ]; then
    eval "$1"
  else
    sudo -E sh -c "$1"
  fi
}

# Detect the OS.
echo "🔍 Detecting OS..."
OS=""
BASH_PATH="/bin/bash"
case "$(uname -s)" in
Darwin)
  OS="macos"
  BASH_PATH="/usr/local/bin/bash"
  ;;
Linux)
  if [ -f "/etc/os-release" ]; then
    OS=$(awk -F= '/^NAME/{print tolower($2)}' /etc/os-release | tr -d '"' | awk '{print $1}')
  fi
  ;;
*)
  echo "OS not supported."
  exit 1
  ;;
esac
echo "✅ OK. Detected OS: $OS"

# Ensure bash is installed
echo "🔧 Ensuring bash is installed..."
case "$OS" in
arch) sudo_if "pacman -Syu bash --noconfirm" ;;
debian | ubuntu) sudo_if "apt-get update -y && apt-get install -y bash" ;;
fedora)
  sudo_if "dnf check-update -y || true"
  sudo_if "dnf install -y bash"
  ;;
rhel) sudo_if "yum check-update -y && yum install -y bash" ;;
macos) sudo_if "brew update && brew install bash" ;;
*)
  echo "OS $OS not supported."
  exit 1
  ;;
esac
echo "✅ OK. Bash is installed."

# Source the util script.
# shellcheck disable=SC1091
# shellcheck source=scripts/util.sh
. scripts/util.sh

debug_system

# Execute main script
echo "🚀 Executing main script (OS:$OS)..."
exec $BASH_PATH "$(dirname "$0")/main.sh" "$OS" "$@"

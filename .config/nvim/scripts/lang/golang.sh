#!/usr/bin/env bash
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Bart Venter.
# Licensed under the MIT License. See https://github.com/bartventer/dotfiles for license information.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/bartventer/dotfiles/tree/main/README.md
# Maintainer: Bart Venter <https://github.com/bartventer>
#
# This script sets up Go development environment.
#
# Usage: ./golang.sh <package_manager> <zsh_local>
# Arguments:
#   - package_manager: The package manager to use. Supported values: pacman, brew, apt,
#     or any other package manager that can be used to install Go.
#   - zsh_local: The path to the zsh_local file.
#
# Example: ./golang.sh pacman $HOME/.zsh_local
#
# This script will:
#   - Install Delve for debugging Go code.
#   - Install golangci-lint for linting Go code.
#   - Generate Zsh autocompletion script for golangci-lint.
#   - Update the zsh_local file with the autocompletion script.
#
# Note: This script assumes that Go is already installed.
#-----------------------------------------------------------------------------------------------------------------

set -e

# Declare and validate arguments
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <package_manager> <zsh_local>"
    exit 1
elif [[ -z $1 ]]; then
    echo "Error: package manager not provided."
    exit 1
elif [[ -z $2 ]] || [[ ! -f $2 ]]; then
    echo "Error: zsh_local not provided or does not exist."
    exit 1
fi

PACKAGE_MANAGER=$1
ZSH_LOCAL=$2

usage() {
    echo "Usage: $0 <package_manager> <zsh_local>"
    exit 1
}

error() {
    log_error "Error: $1"
    usage
}

install_delve() {
    local package_manager=$1
    log_info "Installing Delve..."
    echo "Setting GOPATH for this session..."
    case $package_manager in
    pacman)
        if [[ $CI == "true" ]]; then
            pacman -Syu delve --noconfirm
        else
            sudo pacman -Syu delve --noconfirm
        fi
        ;;
    *)
        go install github.com/go-delve/delve/cmd/dlv@latest
        ;;
    esac
    echo "OK. Delve installed."
}

update_zsh_local() {
    local zsh_local=$1
    local line_to_add=$2
    log_info "Updating ${zsh_local} with ${line_to_add}..."
    if ! grep -q "${line_to_add}" "${zsh_local}"; then
        echo "Line not found. Adding..."
        echo "${line_to_add}" >>"${zsh_local}"
    fi
    echo "OK. ${zsh_local} updated."
}

install_and_setup_golangci_lint() {
    local zsh_local=$1
    log_info "Checking if golangci-lint is installed..."
    if ! command -v golangci-lint &>/dev/null; then
        echo "Installing golangci-lint..."
        go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    fi
    echo "OK. golangci-lint installed."

    log_info "Generating Zsh autocompletion script for golangci-lint..."
    golangci-lint completion zsh >~/.golangci-lint-completion.zsh
    echo "OK. Autocompletion script generated."

    update_zsh_local "${zsh_local}" 'source ~/.golangci-lint-completion.zsh'
}

log_info "Setting up go..."

if ! command -v go &>/dev/null; then
    log_error "go is not installed. Please install it and try again."
    exit 1
fi

# Set up Go environment
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
# Install Go Tools
install_delve "$PACKAGE_MANAGER" "$ZSH_LOCAL"
install_and_setup_golangci_lint "$ZSH_LOCAL"

# ... and other dependencies

log_success "Done. Go setup complete."

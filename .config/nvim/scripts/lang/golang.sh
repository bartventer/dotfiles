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
#   - Install golangci-lint for linting Go code.
#   - Generate Zsh autocompletion script for golangci-lint.
#   - Update the zsh_local file with the autocompletion script.
#   - Installs various Go tools for development.
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
    golangci-lint completion zsh >"${HOME}/.golangci-lint-completion.zsh"
    echo "OK. Autocompletion script generated."

    update_zsh_local "${zsh_local}" "source ${HOME}/.golangci-lint-completion.zsh"
}

log_info "Setting up go..."

if ! command -v go &>/dev/null; then
    log_error "go is not installed. Please install it and try again."
    exit 1
fi

# Set up Go environment
if [[ "${CI}" != "true" ]]; then
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:$PATH"
fi

# Install golangci-lint and set up autocompletion
install_and_setup_golangci_lint "$ZSH_LOCAL"

# Go tools to install
GO_TOOLS="\
    golang.org/x/tools/gopls@latest \
    honnef.co/go/tools/cmd/staticcheck@latest \
    golang.org/x/lint/golint@latest \
    github.com/mgechev/revive@latest \
    github.com/fatih/gomodifytags@latest \
    github.com/haya14busa/goplay/cmd/goplay@latest \
    github.com/cweill/gotests/gotests@latest \
    github.com/josharian/impl@latest \
    github.com/cosmtrek/air@latest"

# Delve installation
if [[ $PACKAGE_MANAGER != "pacman" ]]; then
    GO_TOOLS+=" github.com/go-delve/delve/cmd/dlv@latest"
else
    log_info ":: Installing delve (arch based system)..."
    if [[ $CI == "true" ]]; then
        pacman -Syu delve --noconfirm
    else
        sudo pacman -Syu delve --noconfirm
    fi
fi
log_info "Installing Go tools..."
echo "${GO_TOOLS}" | xargs -n 1 go install

log_success "Done. Go setup complete."

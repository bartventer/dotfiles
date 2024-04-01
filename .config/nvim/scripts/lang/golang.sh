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
#   - Generate Zsh autocompletion script for golangci-lint if it's installed.
#   - Update the zsh_local file with the autocompletion script.
#   - Installs various Go tools for development.
# Note: This script assumes that Go and golangci-lint are already installed.
#-----------------------------------------------------------------------------------------------------------------

set -e

DOTFILES_SCRIPTS_DIR="${DOTFILES_SCRIPTS_DIR:-$HOME/dotfiles/scripts}"
if [[ ! -d $DOTFILES_SCRIPTS_DIR ]]; then
    echo "Error: DOTFILES_SCRIPTS_DIR ($DOTFILES_SCRIPTS_DIR) does not exist."
    exit 1
fi
# shellcheck disable=SC1091
# shellcheck source=scripts/util.sh
. "${DOTFILES_SCRIPTS_DIR}/util.sh"

# Validate arguments
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

log_info "Setting up go..."

if ! command -v go &>/dev/null; then
    log_error "go is not installed. Please install it and try again."
    exit 1
fi

# Set up Go environment
if [[ "${CI}" != "true" ]]; then
    export GOPATH="$HOME/go"
    update_path "$GOPATH/bin"
fi

# Configure golangci-lint
if command -v golangci-lint &>/dev/null; then
    log_info "Generating Zsh autocompletion script for golangci-lint..."
    GOLANGCI_LINT_COMPLETION="${HOME}/.golangci-lint-completion.zsh"
    if [[ ! -f $GOLANGCI_LINT_COMPLETION ]]; then
        golangci-lint completion zsh >"${HOME}/.golangci-lint-completion.zsh"
        echo "OK. Autocompletion script generated."
    fi
    update_zsh_local "$ZSH_LOCAL" "source ${GOLANGCI_LINT_COMPLETION}"
fi

# Go tools to install (not available in Mason.nvim)
# See https://github.com/bartventer/dotfiles/blob/c90c6137fce4dec07b830099cafc791cbfe6ce92/config/config.json#L174
GO_TOOLS="\
    golang.org/x/lint/golint@latest \
    github.com/haya14busa/goplay/cmd/goplay@latest \
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
echo "${GO_TOOLS}" | xargs -n 1 -P 8 go install

log_success "Done. Go setup complete."

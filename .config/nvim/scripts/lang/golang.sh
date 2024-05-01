#!/usr/bin/env bash
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Bart Venter.
# Licensed under the MIT License. See https://github.com/bartventer/dotfiles for license information.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/bartventer/dotfiles/tree/main/README.md
# Maintainer: Bart Venter <https://github.com/bartventer>
#
# This script sets up the Go development environment.
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

CI=${CI:-"false"}
DOTFILES_UTIL_SCRIPT="${DOTFILES_UTIL_SCRIPT:-}"
if [[ -z "${DOTFILES_UTIL_SCRIPT}" || ! -f "${DOTFILES_UTIL_SCRIPT}" ]]; then
    echo "Error: DOTFILES_UTIL_SCRIPT (${DOTFILES_UTIL_SCRIPT}) not set or does not exist."
    exit 1
fi
# shellcheck disable=SC1091
# shellcheck source=scripts/util.sh
source "${DOTFILES_UTIL_SCRIPT}"

# Validate arguments
if [[ $# -ne 2 ]]; then
    log_error "Usage: $0 <package_manager> <zsh_local>"
    exit 1
elif [[ -z $1 ]]; then
    log_error "Error: package manager not provided."
    exit 1
elif [[ -z $2 ]] || [[ ! -f $2 ]]; then
    log_error "Error: zsh_local not provided or does not exist."
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

# Golandci-lint
#https://golangci-lint.run/welcome/install/
GOLANGCI_LINT_VERSION=v1.57.2

# Go tools to install
# See https://github.com/bartventer/dotfiles/blob/master/config/config.json#L174
# Note: Opting not to use Mason for these go packages as it does not use GOPATH/GOBIN.
GO_TOOLS="\
    golang.org/x/tools/gopls@latest \
    github.com/golangci/golangci-lint/cmd/golangci-lint@${GOLANGCI_LINT_VERSION} \
    honnef.co/go/tools/cmd/staticcheck@latest \
    github.com/mgechev/revive@latest \
    github.com/incu6us/goimports-reviser/v2@latest \
    github.com/segmentio/golines@latest \
    github.com/fatih/gomodifytags@latest \
    github.com/cweill/gotests/gotests@latest \
    github.com/josharian/impl@latest \
    golang.org/x/lint/golint@latest \
    github.com/haya14busa/goplay/cmd/goplay@latest \
    github.com/cosmtrek/air@latest \
    github.com/spf13/cobra-cli@latest"

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

log_success "Done. Go setup complete."

#!/bin/bash

set -e

log_info "Setting up GoLang..."

if ! command -v go &>/dev/null; then
    log_error "GoLang is not installed. Please install it and try again."
    exit 1
fi

# Get the package manager from the command-line arguments
PACKAGE_MANAGER=$1

# Check if a package manager was provided
if [ -z "$PACKAGE_MANAGER" ]; then
    log_error "Please provide a package manager as the first argument."
    exit 1
fi

# Install delve
log_info "Installing delve"
# Set the GOPATH
export GOPATH="$HOME/go"
case $PACKAGE_MANAGER in
pacman)
    set -x
    if [ "$CI" = "true" ]; then
        pacman -Syu delve --noconfirm
    else
        sudo pacman -Syu delve --noconfirm
    fi
    set +x
    ;;
*)
    go install github.com/go-delve/delve/cmd/dlv@latest
    ;;
esac

# ... and other dependencies

log_success "GoLang setup complete"

#!/bin/bash

log_info "Setting up GoLang..."

# Get the package manager from the command-line arguments
PACKAGE_MANAGER=$1

# Check if a package manager was provided
if [ -z "$PACKAGE_MANAGER" ]; then
    log_error "Please provide a package manager as the first argument."
    exit 1
fi

# Install delve
log_info "Installing delve"

case $PACKAGE_MANAGER in
pacman)
    if [ "$CI" = "true" ]; then
        pacman -S delve --noconfirm
    else
        sudo pacman -S delve --noconfirm
    fi
    ;;
*)
    go install github.com/go-delve/delve/cmd/dlv@latest
    ;;
esac

# ... and other dependencies

log_success "GoLang setup complete"
#!/bin/bash

# Get the package manager from the command-line arguments
PACKAGE_MANAGER=$1

# Check if a package manager was provided
if [ -z "$PACKAGE_MANAGER" ]; then
    echo "Please provide a package manager as the first argument."
    exit 1
fi

# Install delve
echo "Installing delve"

case $PACKAGE_MANAGER in
pacman)
    sudo pacman -S delve
    ;;
*)
    go install github.com/go-delve/delve/cmd/dlv@latest
    ;;
esac

# ... and other dependencies


echo "Dependencies installation complete"
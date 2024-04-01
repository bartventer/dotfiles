#!/usr/bin/env sh
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Bart Venter.
# Licensed under the MIT License. See https://github.com/bartventer/dotfiles for license information.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/bartventer/dotfiles/tree/main/README.md
# Maintainer: Bart Venter <https://github.com/bartventer>
#
# This script initializes the environment for the application.
# It sets up the environment.
#
# Usage: ./scripts/init.sh
#-----------------------------------------------------------------------------------------------------------------

set -e

# Set DOTFILES_DIR
DOTFILES_DIR=""
if [ "$CI" = "true" ]; then
    DOTFILES_DIR="$GITHUB_WORKSPACE"
else
    DOTFILES_DIR="$(git rev-parse --show-toplevel)"
fi

if [ -z "$DOTFILES_DIR" ] || [ ! -d "$DOTFILES_DIR" ]; then
    echo "Error: DOTFILES_DIR ($DOTFILES_DIR) is not set or does not exist."
    exit 1
fi
export DOTFILES_DIR

# Get the directory of this script
SCRIPT_DIR="${DOTFILES_DIR}/scripts"
if [ ! -d "$SCRIPT_DIR" ]; then
    echo "Error: SCRIPT_DIR ($SCRIPT_DIR) does not exist."
    exit 1
fi
DOTFILES_INIT_SCRIPT="$SCRIPT_DIR/$(basename "$0")"
export DOTFILES_INIT_SCRIPT

# Set the path to the util.sh script
DOTFILES_UTIL_SCRIPT="$SCRIPT_DIR/util.sh"
if [ ! -f "$DOTFILES_UTIL_SCRIPT" ]; then
    echo "Error: util.sh script ($DOTFILES_UTIL_SCRIPT) not found."
    exit 1
fi
export DOTFILES_UTIL_SCRIPT

echo "Initializing..."

# Set DOTFILES_CONFIG_DIR
DOTFILES_CONFIG_DIR="$DOTFILES_DIR/config"
if [ ! -d "$DOTFILES_CONFIG_DIR" ]; then
    echo "Error: DOTFILES_CONFIG_DIR not found."
    exit 1
fi
export DOTFILES_CONFIG_DIR

# Set CONFIG_FILE
CONFIG_FILE="$DOTFILES_CONFIG_DIR/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: CONFIG_FILE not found."
    exit 1
fi
export CONFIG_FILE

# Set DOTFILES_SCRIPTS_DIR
DOTFILES_SCRIPTS_DIR="$DOTFILES_DIR/scripts"
if [ ! -d "$DOTFILES_SCRIPTS_DIR" ]; then
    echo "Error: DOTFILES_SCRIPTS_DIR not found."
    exit 1
fi
export DOTFILES_SCRIPTS_DIR

# Set DOTFILES_FONTS_CONFIG
DOTFILES_FONTS_CONFIG="$DOTFILES_CONFIG_DIR/fonts.json"
if [ ! -f "$DOTFILES_FONTS_CONFIG" ]; then
    echo "Error: DOTFILES_FONTS_CONFIG not found."
    exit 1
fi
export DOTFILES_FONTS_CONFIG

echo "Successfully initialized."

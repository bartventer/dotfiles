#!/bin/bash
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Bart Venter.
# Licensed under the MIT License. See https://github.com/bartventer/dotfiles for license information.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/bartventer/dotfiles/tree/main/README.md
# Maintainer: Bart Venter <https://github.com/bartventer>
#
# This script initializes the environment for the application.
# It sources the log.sh script for logging, sets up the environment,
# and logs a success message.
#
# Usage: ./scripts/init.sh
#
# Dependencies: log.sh
#
set -e
# Get the directory of this script
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
if [[ ! -d "$SCRIPT_DIR" ]]; then
    echo "Error: SCRIPT_DIR ($SCRIPT_DIR) does not exist."
    exit 1
fi
DOTFILES_INIT_SCRIPT="$SCRIPT_DIR/$(basename "${BASH_SOURCE[0]}")"
export DOTFILES_INIT_SCRIPT

# Source the util.sh script
DOTFILES_UTIL_SCRIPT="$SCRIPT_DIR/util.sh"
if [[ ! -f "$DOTFILES_UTIL_SCRIPT" ]]; then
    echo "Error: log.sh script ($DOTFILES_UTIL_SCRIPT) not found."
    exit 1
fi
export DOTFILES_UTIL_SCRIPT

# shellcheck disable=SC1091
# shellcheck source=scripts/util.sh
. "$DOTFILES_UTIL_SCRIPT"

log_info "Initializing..."

# Set DOTFILES_DIR
DOTFILES_DIR=""
if [[ "$CI" == "true" ]]; then
    DOTFILES_DIR="$GITHUB_WORKSPACE"
else
    DOTFILES_DIR="$(git rev-parse --show-toplevel)"
fi

if [[ -z "$DOTFILES_DIR" || ! -d "$DOTFILES_DIR" ]]; then
    log_error "Error: DOTFILES_DIR ($DOTFILES_DIR) is not set or does not exist."
    exit 1
fi
export DOTFILES_DIR

# Set DOTFILES_CONFIG_DIR
DOTFILES_CONFIG_DIR="$DOTFILES_DIR/config"
if [[ ! -d "$DOTFILES_CONFIG_DIR" ]]; then
    log_error "Error: DOTFILES_CONFIG_DIR not found."
    exit 1
fi
export DOTFILES_CONFIG_DIR

# Set CONFIG_FILE
CONFIG_FILE="$DOTFILES_CONFIG_DIR/config.json"
if [[ ! -f "$CONFIG_FILE" ]]; then
    log_error "Error: CONFIG_FILE not found."
    exit 1
fi
export CONFIG_FILE

# Set DOTFILES_SCRIPTS_DIR
DOTFILES_SCRIPTS_DIR="$DOTFILES_DIR/scripts"
if [[ ! -d "$DOTFILES_SCRIPTS_DIR" ]]; then
    log_error "Error: DOTFILES_SCRIPTS_DIR not found."
    exit 1
fi
export DOTFILES_SCRIPTS_DIR

# Set DOTFILES_FONTS_CONFIG
DOTFILES_FONTS_CONFIG="$DOTFILES_CONFIG_DIR/fonts.json"
if [[ ! -f "$DOTFILES_FONTS_CONFIG" ]]; then
    log_error "Error: DOTFILES_FONTS_CONFIG not found."
    exit 1
fi
export DOTFILES_FONTS_CONFIG

log_success "Successfully initialized."

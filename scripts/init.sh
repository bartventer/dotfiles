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
CI="${CI:-false}"
if [ "$CI" = "true" ]; then
    DOTFILES_DIR="$GITHUB_WORKSPACE"
else
    DOTFILES_DIR="$(git rev-parse --show-toplevel)"
fi

if [ -z "$DOTFILES_DIR" ] || [ ! -d "$DOTFILES_DIR" ]; then
    echo "Error: DOTFILES_DIR ($DOTFILES_DIR) is not set or does not exist."
    exit 1
fi

# Get the directory of this script
DOTFILES_SCRIPT_DIR="${DOTFILES_DIR}/scripts"
if [ ! -d "$DOTFILES_SCRIPT_DIR" ]; then
    echo "Error: DOTFILES_SCRIPT_DIR ($DOTFILES_SCRIPT_DIR) does not exist."
    exit 1
fi
DOTFILES_INIT_SCRIPT="$DOTFILES_SCRIPT_DIR/$(basename "$0")"

# Set the path to the util.sh script
DOTFILES_UTIL_SCRIPT="$DOTFILES_SCRIPT_DIR/util.sh"
if [ ! -x "$DOTFILES_UTIL_SCRIPT" ]; then
    echo "Error: util.sh script ($DOTFILES_UTIL_SCRIPT) not found/missing execute permission..."
    exit 1
fi

echo "Initializing..."

# Set DOTFILES_CONFIG_DIR
DOTFILES_CONFIG_DIR="$DOTFILES_DIR/config"
if [ ! -d "$DOTFILES_CONFIG_DIR" ]; then
    echo "Error: DOTFILES_CONFIG_DIR not found."
    exit 1
fi

# Set DOTFILES_CONFIG_PATH
DOTFILES_CONFIG_PATH="$DOTFILES_CONFIG_DIR/config.json"
if [ ! -r "$DOTFILES_CONFIG_PATH" ]; then
    echo "Error: DOTFILES_CONFIG_PATH not found/missing read permission..."
    exit 1
fi

# Set DOTFILES_SCRIPTS_DIR
DOTFILES_SCRIPTS_DIR="$DOTFILES_DIR/scripts"
if [ ! -d "$DOTFILES_SCRIPTS_DIR" ]; then
    echo "Error: DOTFILES_SCRIPTS_DIR not found."
    exit 1
fi

# Set DOTFILES_FONTS_PATH
DOTFILES_FONTS_PATH="$DOTFILES_CONFIG_DIR/fonts.json"
if [ ! -r "$DOTFILES_FONTS_PATH" ]; then
    echo "Error: DOTFILES_FONTS_PATH not found/missing read permission..."
    exit 1
fi

# Set DOTFILES_REQUIREMENTS
DOTFILES_REQUIREMENTS="${DOTFILES_DIR}/requirements.txt"
if [ ! -r "${DOTFILES_REQUIREMENTS}" ]; then
    echo "Requirements file (${DOTFILES_REQUIREMENTS}) not found/missing read permission..."
    exit 1
fi

# Set DOTFILES_TOOLS_DIR
DOTFILES_TOOLS_DIR="${DOTFILES_DIR}/tools"
if [ ! -d "${DOTFILES_TOOLS_DIR}" ]; then
    echo "Tools directory (${DOTFILES_TOOLS_DIR}) not found..."
    exit 1
fi

# Set DOTFILES_ACTIVATE_VENV
DOTFILES_ACTIVATE_VENV="${DOTFILES_TOOLS_DIR}/activate-venv.sh"
if [ ! -x "${DOTFILES_ACTIVATE_VENV}" ]; then
    echo "Virtual environment script (${DOTFILES_ACTIVATE_VENV}) not found/missing execute permission..."
    exit 1
fi

# Set DOTFILES_FETCH_FONTS_SCRIPT
DOTFILES_FETCH_FONTS_SCRIPT="${DOTFILES_TOOLS_DIR}/fetch_fonts.py"
if [ ! -x "${DOTFILES_FETCH_FONTS_SCRIPT}" ]; then
    echo "Fetch fonts script (${DOTFILES_FETCH_FONTS_SCRIPT}) not found/missing execute permission..."
    exit 1
fi

# Set DOTFILES_UPDATE_FONTS_SCRIPT
DOTFILES_UPDATE_FONTS_SCRIPT="${DOTFILES_TOOLS_DIR}/update_fonts.sh"
if [ ! -f "${DOTFILES_UPDATE_FONTS_SCRIPT}" ]; then
    echo "Update fonts script (${DOTFILES_UPDATE_FONTS_SCRIPT}) not found..."
    exit 1
fi

# Escaped version of VENVS_DIR
VENVS_DIR_ESCAPED="\${HOME}/.venvs"
# Escaped version of NVIM_VENV_DIR
NVIM_VENV_DIR_ESCAPED="${VENVS_DIR_ESCAPED}/nvim"

# Neovim
NVIM_CONFIG_DIR="$DOTFILES_DIR/.config/nvim"
NVIM_SCRIPTS_DIR="${NVIM_CONFIG_DIR}/scripts"
NVIM_OPTIONS_FILE="${NVIM_CONFIG_DIR}/lua/core/options.lua"
NVIM_LANGUAGE_SCRIPT_DIR="${NVIM_SCRIPTS_DIR}/lang"

# Export variables
export DOTFILES_DIR
export DOTFILES_INIT_SCRIPT
export DOTFILES_UTIL_SCRIPT
export DOTFILES_CONFIG_DIR
export DOTFILES_CONFIG_PATH
export DOTFILES_SCRIPTS_DIR
export DOTFILES_FONTS_PATH
export DOTFILES_REQUIREMENTS

export VENVS_DIR_ESCAPED
export NVIM_VENV_DIR_ESCAPED

# NVIM
export NVIM_CONFIG_DIR
export NVIM_SCRIPTS_DIR
export NVIM_OPTIONS_FILE
export NVIM_LANGUAGE_SCRIPT_DIR

echo "Successfully initialized."

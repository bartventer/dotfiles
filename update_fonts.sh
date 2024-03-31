#!/bin/bash

# update_fonts.sh
#
# Description: This script updates the fonts for the system. It checks for necessary dependencies, sets up a Python virtual environment, installs requirements, and fetches the fonts.
#
# Globals:
#   DOTFILES_DIR: The directory containing the dotfiles.
#   DOTFILES_REQUIREMENTS: The path to the Python requirements file.
#   FETCH_FONTS_SCRIPT: The path to the Python script that fetches the fonts.
#   VENVS_DIR: The directory for Python virtual environments.
#   DOTFILES_VENV_DIR: The directory for the Python virtual environment for this script.
#   PYTHON_CMD: The command to run Python.
#   DOTFILES_VENV_ACTIVATE: The path to the script that activates the Python virtual environment.
#   PIP_CMD: The command to run pip.
#
# Usage:
#   Run this script to update the fonts. For example:
#     ./update_fonts.sh
#

set -e

# Initialization
# shellcheck disable=SC1091
# shellcheck source=init.sh
source "init.sh"

log_info "Starting fonts update..."
DOTFILES_REQUIREMENTS="${DOTFILES_DIR}/requirements.txt"
if [[ ! -f "${DOTFILES_REQUIREMENTS}" ]]; then
    log_error "Requirements file (${DOTFILES_REQUIREMENTS}) not found..."
    exit 1
fi
FETCH_FONTS_SCRIPT="${DOTFILES_SCRIPTS_DIR}/fetch_fonts.py"
if [[ ! -f "${FETCH_FONTS_SCRIPT}" ]]; then
    log_error "Fetch fonts script (${FETCH_FONTS_SCRIPT}) not found..."
    exit 1
fi

VENVS_DIR=${VENVS_DIR:-""}
if [[ -z "$VENVS_DIR" || ! -d "$VENVS_DIR" ]]; then
    log_error "VENVS_DIR not set or directory does not exists..."
    exit 1
fi
DOTFILES_VENV_DIR="${VENVS_DIR}/dotfiles"
if [[ ! -d "${DOTFILES_VENV_DIR}" ]]; then
    mkdir -p "${DOTFILES_VENV_DIR}"
fi
PYTHON_CMD=$(command -v python3 || command -v python)
if [[ -z "${PYTHON_CMD}" ]]; then
    log_error "Python is not installed. Please install Python and run this script again."
    exit 1
fi
DOTFILES_VENV_ACTIVATE="${DOTFILES_VENV_DIR}/bin/activate"
if [[ ! -f "${DOTFILES_VENV_ACTIVATE}" ]]; then
    log_info "Creating virtual environment for Fonts..."
    "${PYTHON_CMD}" -m venv "${DOTFILES_VENV_DIR}"
    echo "OK. Virtual environment created successfully!"
fi
# shellcheck disable=SC1090
source "${DOTFILES_VENV_ACTIVATE}"

PIP_CMD=$(command -v pip3 || command -v pip)
if [[ -z "${PIP_CMD}" ]]; then
    log_error "pip is not installed. Please install pip and run this script again."
    deactivate
    exit 1
fi

# Install python requirements
log_info "Installing python requirements (${DOTFILES_REQUIREMENTS})..."
"${PIP_CMD}" install --upgrade pip && "${PIP_CMD}" install -r "${DOTFILES_REQUIREMENTS}"
echo "OK. Python requirements installed."

# Fetch fonts
log_info "Fetching fonts..."
"${PYTHON_CMD}" "${FETCH_FONTS_SCRIPT}"
echo "OK. Fonts fetched."

# Deactivate venv
log_info "Deactivating virtual environment..."
deactivate

log_success "Fonts update complete."

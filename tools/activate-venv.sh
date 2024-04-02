#!/usr/bin/env bash

# This script creates and activates a Python virtual environment, then installs the specified Python requirements.
#
# Arguments:
#   REQUIREMENTS_FILE: (Optional) The path to the Python requirements file. Default: $DOTFILES_REQUIREMENTS.
#
# Globals:
#   VENVS_DIR: The directory for Python virtual environments.
#   DOTFILES_VENV_DIR: The directory for the Python virtual environment for this script.
#   DOTFILES_VENV_ACTIVATE: The path to the script that activates the Python virtual environment.
#   DOTFILES_PIP_CMD: The command to run pip.
#
# The script will exit with an error if any of the required arguments or globals are not provided,
# or if Python or pip are not installed.
#
# Usage:
#   ./activate-venv.sh <path_to_requirements_file>

set -euo pipefail

# Arguments
set +u
DOTFILES_DIR=${DOTFILES_DIR:-""}
if [ "$CI" = "true" ]; then
    DOTFILES_DIR="$GITHUB_WORKSPACE"
elif [ -z "$DOTFILES_DIR" ]; then
    DOTFILES_DIR="$(git rev-parse --show-toplevel)"
fi
set -u

if [ -x "$DOTFILES_DIR/scripts/init.sh" ]; then
    # shellcheck disable=SC1091
    # shellcheck source=scripts/init.sh
    source "$DOTFILES_DIR/scripts/init.sh"
else
    echo "Error: DOTFILES_DIR ($DOTFILES_DIR) is not set or does not exist."
    exit 1
fi

REQUIREMENTS_FILE="${1:-"${DOTFILES_REQUIREMENTS}"}"
VENVS_DIR="${VENVS_DIR:-"$(eval echo "$VENVS_DIR_ESCAPED")"}"

set +u
# shellcheck disable=SC1091
# shellcheck source=scripts/util.sh
source "${DOTFILES_UTIL_SCRIPT}"
set -u

# Sytem Venvs directory
if [[ -z "$VENVS_DIR" || ! -d "$VENVS_DIR" ]]; then
    log_warn "VENVS_DIR ($VENVS_DIR) does not exist. Creating..."
    mkdir -p "$VENVS_DIR"
    echo "OK. VENVS_DIR created successfully!"
fi
DOTFILES_VENV_DIR="${VENVS_DIR}/dotfiles"
if [[ ! -d "${DOTFILES_VENV_DIR}" ]]; then
    mkdir -p "${DOTFILES_VENV_DIR}"
fi

# OS Python command
PYTHON_CMD=$(command -v python3 || command -v python)
if [[ -z "${PYTHON_CMD}" ]]; then
    log_error "Python is not installed. Please install Python and run this script again."
    exit 1
fi
DOTFILES_VENV_BIN_DIR="${DOTFILES_VENV_DIR}/bin"
DOTFILES_VENV_ACTIVATE="${DOTFILES_VENV_BIN_DIR}/activate"
if [[ ! -x "${DOTFILES_VENV_ACTIVATE}" ]]; then
    log_info "Creating virtual environment for Fonts..."
    "${PYTHON_CMD}" -m venv "${DOTFILES_VENV_DIR}"
    echo "OK. Virtual environment created successfully!"
fi

DOTFILES_PYTHON_CMD="${DOTFILES_VENV_BIN_DIR}/python"
if [[ ! -f "${DOTFILES_PYTHON_CMD}" ]]; then
    log_error "Python command not found in virtual environment. Please recreate the virtual environment."
    exit 1
fi
echo "OK. Python command found in virtual environment."

log_info "Activating virtual environment (${DOTFILES_VENV_ACTIVATE})..."
# shellcheck disable=SC1090
source "${DOTFILES_VENV_ACTIVATE}"
echo "OK. Virtual environment activated."

# Deactivate venv
deactivate_venv() {
    log_info "Deactivating virtual environment..."
    set +u
    if [[ -n "${VIRTUAL_ENV}" ]]; then
        deactivate
    fi
    set -u
    echo "OK. Virtual environment deactivated."
}

log_info "Checking for pip..."
DOTFILES_PIP_CMD=$(command -v pip3 || command -v pip)
if [[ -z "${DOTFILES_PIP_CMD}" ]]; then
    log_error "pip is not installed. Please install pip and run this script again."
    deactivate_venv
    exit 1
fi
echo "OK. pip found."

# Install python requirements
log_info "Installing python requirements (${REQUIREMENTS_FILE})..."
"${DOTFILES_PIP_CMD}" install --upgrade pip &&
    "${DOTFILES_PIP_CMD}" install -r "${REQUIREMENTS_FILE}"
echo "OK. Python requirements installed."

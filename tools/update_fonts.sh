#!/usr/bin/env bash
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Bart Venter.
# Licensed under the MIT License. See https://github.com/bartventer/dotfiles for license information.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/bartventer/dotfiles/tree/main/README.md
# Maintainer: Bart Venter <https://github.com/bartventer>
#
# update_fonts.sh
#
# Description: This script updates the fonts for the system. It checks for necessary dependencies, sets up a Python virtual environment, installs requirements, and fetches the fonts.
#
# Globals:
#   DOTFILES_DIR: The directory containing the dotfiles.
#   DOTFILES_REQUIREMENTS: The path to the Python requirements file.
#   DOTFILES_FETCH_FONTS_SCRIPT: The path to the Python script that fetches the fonts.
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

set -euo pipefail

CI=${CI:-"false"}
GIT_ROOT="${DOTFILES_DIR:-""}"

set +u
if [[ "${CI}" == "true" ]]; then
    GIT_ROOT="${GITHUB_WORKSPACE}"
elif [[ -z "${GIT_ROOT}" ]]; then
    GIT_ROOT=$(git rev-parse --show-toplevel)
fi
set -u

# Initialization
DOTFILES_SCRIPTS_DIR="${DOTFILES_SCRIPTS_DIR:-"${GIT_ROOT}/scripts"}"
if [[ ! -d "${DOTFILES_SCRIPTS_DIR}" ]]; then
    echo "Error: DOTFILES_SCRIPTS_DIR (${DOTFILES_SCRIPTS_DIR}) does not exist."
    exit 1
fi
# shellcheck disable=SC1091
# shellcheck source=scripts/init.sh
. "${DOTFILES_SCRIPTS_DIR}/init.sh"

# shellcheck disable=SC1091
# shellcheck source=scripts/util.sh
. "${DOTFILES_UTIL_SCRIPT}"

log_info "🚀 Starting fonts update..."

echo "DOTFILES_REQUIREMENTS: ${DOTFILES_REQUIREMENTS}"
# Venv script
# shellcheck disable=SC1091
# shellcheck source=tools/activate-venv.sh
. "${DOTFILES_ACTIVATE_VENV}" "${DOTFILES_REQUIREMENTS}"

# Fetch fonts
log_info "Fetching fonts..."
"${DOTFILES_PYTHON_CMD}" "${DOTFILES_FETCH_FONTS_SCRIPT}"
echo "OK. Fonts fetched."

# Deactivate venv
deactivate_venv

log_success "Done. Fonts updated successfully."

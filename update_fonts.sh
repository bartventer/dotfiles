#!/bin/bash

# update_fonts.sh
# 
# Description: This script updates the fonts for the system. It checks for necessary dependencies, sets up a Python virtual environment, installs requirements, and fetches the fonts.
# 
# Functions:
#   check_dependency(dep): Checks if a dependency is installed. If not, logs an error message and exits the script.
#   setup_venv(): Sets up a Python virtual environment if it doesn't already exist.
#   install_requirements(): Installs the Python requirements from a requirements.txt file.
#   fetch_fonts(): Runs a Python script to fetch the fonts.
# 
# Globals:
#   VENV_DIR: The directory for the Python virtual environment.
#   PYTHON_PATH: The path to the Python interpreter in the virtual environment.
# 
# Usage:
#   Run this script to update the fonts. For example:
#     ./update_fonts.sh
# 
# Note:
#   This script sources a script called init.sh, which should be in the same directory.

set -e

# Initialization
# shellcheck disable=SC1091
source "init.sh"

VENV_DIR="venv"
PYTHON_PATH="$VENV_DIR/bin/python"

check_dependency() {
    if ! command -v "$1" &> /dev/null
    then
        log_error "$1 could not be found. Please install $1 to run this script."
        exit
    fi
}

setup_venv() {
    if [ ! -d  "$VENV_DIR" ]
    then
        log_info "Creating virtual environment..."
        python3 -m venv "$VENV_DIR"
    fi
}

install_requirements() {
    "$PYTHON_PATH" -m pip install -r "$DOTFILES_DIR/requirements.txt"
}

fetch_fonts() {
    "$PYTHON_PATH" "$DOTFILES_SCRIPTS_DIR/fetch_fonts.py"
}

log_info "Starting fonts update..."

# Check for necessary dependencies
log_info "Checking for necessary dependencies..."
for dep in "python3" "pip"
do
    check_dependency "$dep"
done

# Set up Python virtual environment and install requirements
log_info "Setting up Python virtual environment and installing requirements..."
setup_venv

# Install requirements
log_info "Installing requirements..."
install_requirements

# Fetch fonts
log_info "Fetching fonts..."
fetch_fonts

log_success "Fonts update complete."
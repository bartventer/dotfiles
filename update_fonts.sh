#!/bin/bash

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
    "$PYTHON_PATH" -m pip install -r "$(dirname "$0")/requirements.txt"
}

fetch_fonts() {
    "$PYTHON_PATH" "$(dirname "$0")/scripts/fetch_fonts.py"
}

log_info "Starting fonts update..."

# Check for necessary dependencies
log_info "Checking for necessary dependencies..."
check_dependency "python3"
check_dependency "pip"

# Set up Python virtual environment and install requirements
log_info "Setting up Python virtual environment and installing requirements..."
setup_venv

# Install requirements
log_info "Installing requirements..."
install_requirements

# Fetch fonts
log_info "Fetching fonts..."
fetch_fonts

log_success "Fonts updated successfully!"
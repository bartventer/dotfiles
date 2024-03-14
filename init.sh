#!/bin/bash
# 
# This script initializes the environment for the application.
# It sources the log.sh script for logging, runs the env_setup.py script to set up the environment,
# and logs a success message.
# 
# Usage: ./init.sh
# 
# Dependencies: log.sh, env_setup.py
# 
set -e

# shellcheck disable=SC1091
source "$(dirname "$0")/scripts/log.sh"

log_info "Initializing..."

eval "$(./env_setup.py)"

log_success "Successfully initialized."
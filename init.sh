#!/bin/bash

# Source the log script file
# shellcheck disable=SC1091
source "$(dirname "$0")/scripts/log.sh"

log_info "Initializing..."

REPO_DIR="$(dirname "$(realpath "$0")")"
export REPO_DIR

log_success "Successfully initialized."
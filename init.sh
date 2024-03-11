#!/bin/bash

# shellcheck disable=SC1091
source "$(dirname "$0")/scripts/log.sh"

log_info "Initializing..."
if [ "${CI}" == "true" ]; then
    REPO_DIR="${GITHUB_WORKSPACE}"
elif [ "$(uname)" == "Linux" ]; then
    REPO_DIR="$(dirname "$(realpath "$0")")"
elif [ "$(uname)" == "Darwin" ]; then
    REPO_DIR="$(python -c "import os; print(os.path.dirname(os.path.realpath('$0')))")"
else
    log_error "Unsupported OS"
    exit 1
fi
export REPO_DIR

log_success "Successfully initialized."
#!/bin/bash

# shellcheck disable=SC1091
source "$(dirname "$0")/scripts/log.sh"

log_info "Initializing..."

if [ "$(uname)" == "Darwin" ]; then
    REPO_DIR="$(python -c "import os; print(os.path.dirname(os.path.realpath('$0')))")"
else
    REPO_DIR="$(dirname "$(realpath "$0")")"
fi
export REPO_DIR

log_success "Successfully initialized."
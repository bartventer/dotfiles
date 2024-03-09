#!/bin/bash

# *******************
# ** Color logging **
# *******************

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
INFO='\033[0;36m'
NC='\033[0m' # No Color

log_success() {
    echo -e "${GREEN}$1${NC}"
}

log_warn() {
    echo -e "${YELLOW}$1${NC}"
}

log_error() {
    echo -e "${RED}$1${NC}"
}

log_info() {
    echo -e "${INFO}$1${NC}"
}
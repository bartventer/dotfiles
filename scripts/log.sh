#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
INFO='\033[1;36m'
TRACE='\033[1;35m'  # New color code for trace level logs
NC='\033[0m' # No Color

LOG_LEVEL=0

log_message() {
    local level=$1
    local color=$2
    local message=$3
    local func_name=$4
    local line_number=$5
    local file_name=$6

    if [ "$level" -ge "$LOG_LEVEL" ]; then
        local timestamp
        timestamp=$(TZ=UTC date +"%Y-%m-%d %H:%M:%S")
        if [ "$level" -eq "4" ]; then  # If level is 4 (trace), print function name
            echo -e "\n${NC}[${color}${timestamp}${NC}][${color}${file_name}:${line_number}${NC}][${color}${func_name}${NC}]"
        else
            echo -e "\n${NC}[${color}${timestamp}${NC}][${color}${file_name}:${line_number}${NC}]"
        fi
        echo -e "${NC}${message}"  # Message is now white
    fi
}

log_success() {
    log_message 0 "$GREEN" "$1" "${FUNCNAME[1]}" "${BASH_LINENO[0]}" "${BASH_SOURCE[1]}"
}

log_info() {
    log_message 1 "$INFO" "$1" "${FUNCNAME[1]}" "${BASH_LINENO[0]}" "${BASH_SOURCE[1]}"
}

log_warn() {
    log_message 2 "$YELLOW" "$1" "${FUNCNAME[1]}" "${BASH_LINENO[0]}" "${BASH_SOURCE[1]}"
}

log_error() {
    log_message 3 "$RED" "$1" "${FUNCNAME[1]}" "${BASH_LINENO[0]}" "${BASH_SOURCE[1]}"
}

log_trace() {
    log_message 4 "$TRACE" "$1" "${FUNCNAME[1]}" "${BASH_LINENO[0]}" "${BASH_SOURCE[1]}"
}
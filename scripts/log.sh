#!/bin/bash

# log.sh
# 
# Description: This script provides a logging utility for bash scripts. It supports different log levels and colors for different types of logs.
# 
# Functions:
#   log_message(level, color, message, func_name, line_number, file_name): Logs a message with a given level, color, and source information.
#   log_success(message): Logs a success message (green).
#   log_info(message): Logs an informational message (cyan).
#   log_warn(message): Logs a warning message (yellow).
#   log_error(message): Logs an error message (red).
#   log_trace(message): Logs a trace message (purple), including the function name.
# 
# Globals:
#   RED, GREEN, YELLOW, INFO, TRACE, NC: Color codes for log messages.
#   LOG_LEVEL: The minimum log level to display.
#   FUNCNAME_INDEX, LINENO_INDEX, SOURCE_INDEX: Indices for shell-specific arrays.
# 
# Usage:
#   Source this script in your bash script, then call the log functions. For example:
#     source log.sh
#     log_info "This is an informational message."
#     log_error "This is an error message."
# 
# Note:
#   This script checks if it's running in zsh or bash and adjusts array indices accordingly.

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
INFO='\033[1;36m'
TRACE='\033[1;35m'  # New color code for trace level logs
NC='\033[0m' # No Color

LOG_LEVEL=0

# Determine shell and adjust array indices
if [ -n "$ZSH_VERSION" ]; then
    FUNCNAME_INDEX=2
    LINENO_INDEX=1
    SOURCE_INDEX=2
else
    FUNCNAME_INDEX=1
    LINENO_INDEX=0
    SOURCE_INDEX=1
fi

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
    log_message 0 "$GREEN" "$1" "${FUNCNAME[$FUNCNAME_INDEX]}" "${BASH_LINENO[$LINENO_INDEX]}" "${BASH_SOURCE[$SOURCE_INDEX]}"
}

log_info() {
    log_message 1 "$INFO" "$1" "${FUNCNAME[$FUNCNAME_INDEX]}" "${BASH_LINENO[$LINENO_INDEX]}" "${BASH_SOURCE[$SOURCE_INDEX]}"
}

log_warn() {
    log_message 2 "$YELLOW" "$1" "${FUNCNAME[$FUNCNAME_INDEX]}" "${BASH_LINENO[$LINENO_INDEX]}" "${BASH_SOURCE[$SOURCE_INDEX]}"
}

log_error() {
    log_message 3 "$RED" "$1" "${FUNCNAME[$FUNCNAME_INDEX]}" "${BASH_LINENO[$LINENO_INDEX]}" "${BASH_SOURCE[$SOURCE_INDEX]}"
}

log_trace() {
    log_message 4 "$TRACE" "$1" "${FUNCNAME[$FUNCNAME_INDEX]}" "${BASH_LINENO[$LINENO_INDEX]}" "${BASH_SOURCE[$SOURCE_INDEX]}"
}
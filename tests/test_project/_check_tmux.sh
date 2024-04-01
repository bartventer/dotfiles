#!/usr/bin/env bash

# shellcheck disable=SC1091
# shellcheck source=test-utils.sh
source test-utils.sh

check_tmux_and_plugins() {
    # Initialize the status
    status=0

    # Check if tmux is installed
    if ! check "tmux" "command -v tmux"; then
        status=1
    fi

    # Get the config file location from the first argument
    config_file="$1"

    # Load the plugins from the JSON file
    plugins=$(jq -r '.tmux_plugins | keys[]' "$config_file")

    for plugin in $plugins; do
        if ! check "[tmux] Plugin ${plugin}" "[ -d ~/.tmux/plugins/${plugin} ]"; then
            status=1
        fi
    done

    return $status
}

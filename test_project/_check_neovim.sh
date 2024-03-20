#!/bin/bash

# shellcheck disable=SC1091
source test-utils.sh

check_neovim_and_plugins() {
    # Initialize the status
    status=0

    # Check if Neovim is installed
    if ! check "Neovim" "command -v nvim"; then
        status=1
    fi

    # Get the config file location from the first argument
    config_file="$1"

    # Load the plugins from the JSON file
    plugins=$(jq -r '.neovim | .[] | .[]' "$config_file")

    if [ -z "$plugins" ]; then
        echo "No Neovim plugins found in the config file."
        status=1
    else
        for plugin in $plugins
        do
            if ! check "[Neovim] Plugin ${plugin}" "nvim --headless +\":silent! echo exists('g:${plugin}')\" +\":q\""; then
                status=1
            fi
        done
    fi

    return $status
}
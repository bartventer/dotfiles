#!/bin/bash

# shellcheck disable=SC1091
# shellcheck source=test-utils.sh
source test-utils.sh

check_zsh_and_plugins() {
    # Initialize the status
    status=0

    # Check if zsh is installed
    if ! check "zsh" "zsh --version"; then
        status=1
    fi

    # Get the config file location from the first argument
    config_file="$1"

    # Load the plugins from the JSON file
    plugins=$(jq -r '.ohmyzsh_plugins | keys[]' "$config_file")

    for plugin in $plugins; do
        if ! check "[zsh] Plugin ${plugin}" "[ -d $HOME/.oh-my-zsh/custom/plugins/${plugin} ]"; then
            status=1
        fi
    done

    return $status
}

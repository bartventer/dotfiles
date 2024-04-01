#!/bin/bash

# shellcheck disable=SC1091
# shellcheck source=test-utils.sh
source test-utils.sh

check_neovim_and_plugins() {
    # Initialize the status
    status=0

    # Check if Neovim is installed
    if ! check "Neovim" "command -v nvim"; then
        status=1
    fi

    # # Get the config file location from the first argument # todo add test for config file
    # config_file="$1"

    # # Load the plugins from the JSON file
    # # parsers=$(jq -r '.neovim.parsers | .[]' "$config_file") # todo add test for parsers
    # lsps=$(jq -r '.neovim.lsps | .[]' "$config_file")
    # daps=$(jq -r '.neovim.daps | .[]' "$config_file")
    # linters=$(jq -r '.neovim.linters | .[]' "$config_file")
    # formatters=$(jq -r '.neovim.formatters | .[]' "$config_file")

    # # Check if the language servers, debug adapters, linters, and formatters are installed
    # for component in $lsps $daps $linters $formatters
    # do
    #     output=$(nvim --headless +"lua print(require('mason-registry').is_installed('${component}'))" +q)
    #     if [ "$output" = "true" ]; then
    #         check_command="exit 0"
    #     else
    #         check_command="exit 1"
    #     fi
    #     if ! check "[Neovim] Mason ${component}" "$check_command"; then
    #         status=1
    #     fi
    # done

    return $status
}

#!/bin/bash
cd "$(dirname "$0")" || exit

source ../scripts/util.sh
source ../scripts/log.sh

debug_system

log_info "Running tests..."

# shellcheck disable=SC1091
source test-utils.sh

source _check_packages.sh

source _check_zsh.sh

source _check_neovim.sh

source _check_tmux.sh

# Run common tests
checkCommon

# Check if bash is installed and updated
check "Bash" "bash --version"
check "jq" "jq --version"
check "curl" "curl --version"
check "git" "git --version"

# Get the path to the JSON Config file
script_dir=$(cd "$(dirname "$0")"; pwd)
config_file="${script_dir}/../config/config.json"

# Check if zsh and plugins are installed
check_zsh_and_plugins "$config_file"
check "Oh My Zsh! (Powerlevel10k) theme" "test -e \"$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme\""

# Check if Common packages and Distro-specific packages are installed
check_packages "$config_file"

# Check if Neovim and plugins are installed
check_neovim_and_plugins "$config_file"

# Check if tmux and plugins are installed
check_tmux_and_plugins "$config_file"

# Report results
reportResults
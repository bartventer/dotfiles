#!/usr/bin/env bash

DOTFILES_DIR=""
if [[ $CI == "true" ]]; then
    DOTFILES_DIR=${GITHUB_WORKSPACE}
else
    DOTFILES_DIR=$(git rev-parse --show-toplevel)
fi
if [[ ! -f "$DOTFILES_DIR/scripts/init.sh" ]]; then
    echo "Cannot find init.sh script"
    exit 1
fi
# shellcheck disable=SC1091
# shellcheck source=../../scripts/init.sh
source "$DOTFILES_DIR/scripts/init.sh"

# shellcheck disable=SC1091
# shellcheck source="${DOTFILES_UTIL_SCRIPT}"
source "${DOTFILES_UTIL_SCRIPT}"

debug_system

log_info "Running tests..."
# shellcheck disable=SC1091
# shellcheck source=test-utils.sh
source test-utils.sh
# shellcheck disable=SC1091
# shellcheck source=_check_packages.sh
source _check_packages.sh
# shellcheck disable=SC1091
# shellcheck source=_check_zsh.sh
source _check_zsh.sh
# shellcheck disable=SC1091
# shellcheck source=_check_neovim.sh
source _check_neovim.sh
# shellcheck disable=SC1091
# shellcheck source=_check_tmux.sh
source _check_tmux.sh

# Run common tests
checkCommon

# Check if bash is installed and updated
check "Bash" "bash --version"
check "jq" "jq --version"
check "curl" "curl --version"
check "git" "git --version"

# Get the path to the JSON Config file
config_file="../../config/config.json"
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

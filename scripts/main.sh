#!/usr/bin/env bash
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Bart Venter.
# Licensed under the MIT License. See https://github.com/bartventer/dotfiles for license information.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/bartventer/dotfiles/tree/main/README.md
# Maintainer: Bart Venter <https://github.com/bartventer>
#
# This script installs the dotfiles on your system.
# It configures permissions (if not macOS), installs zsh and oh-my-zsh, creates symbolic links, installs packages,
# clones oh-my-zsh and tmux plugins, configures Docker, installs oh-my-zsh theme, fonts, and Neovim with its dependencies.
# It also sources the .zshrc file.
#
# Usage: ./main.sh <distro> [additional_arguments...]
#
# Arguments:
#   - distro: The distribution of the operating system. This argument is required.
#   - additional_arguments: Any additional arguments to be passed to the script.
#
# Dependencies: zsh, git, curl, jq, unzip, wget
#-----------------------------------------------------------------------------------------------------------------
set -e

CI=${CI:-"false"}
DOTFILES_UTIL_SCRIPT="${DOTFILES_UTIL_SCRIPT:-}"
if [[ -z "${DOTFILES_UTIL_SCRIPT}" || ! -f "${DOTFILES_UTIL_SCRIPT}" ]]; then
    echo "Error: DOTFILES_UTIL_SCRIPT (${DOTFILES_UTIL_SCRIPT}) not set or does not exist."
    exit 1
fi
DOTFILES_DIR=${DOTFILES_DIR:-}
if [[ -z "${DOTFILES_DIR}" || ! -d "${DOTFILES_DIR}" ]]; then
    echo "Error: DOTFILES_DIR (${DOTFILES_DIR}) is not set or does not exist."
    exit 1
fi
DOTFILES_CONFIG_PATH="${DOTFILES_CONFIG_PATH:-}"
if [[ -z "${DOTFILES_CONFIG_PATH}" || ! -f "${DOTFILES_CONFIG_PATH}" ]]; then
    echo "Error: DOTFILES_CONFIG_PATH (${DOTFILES_CONFIG_PATH}) is not set or does not exist."
    exit 1
fi
VENVS_DIR_ESCAPED="${VENVS_DIR_ESCAPED:-}"
if [[ -z "${VENVS_DIR_ESCAPED}" ]]; then
    echo "Error: VENVS_DIR_ESCAPED (${VENVS_DIR_ESCAPED}) is not set."
    exit 1
fi
NVIM_VENV_DIR_ESCAPED="${NVIM_VENV_DIR_ESCAPED:-}"
if [[ -z "${NVIM_VENV_DIR_ESCAPED}" ]]; then
    echo "Error: NVIM_VENV_DIR_ESCAPED (${NVIM_VENV_DIR_ESCAPED}) is not set."
    exit 1
fi

# shellcheck disable=SC1091
# shellcheck source=scripts/util.sh
source "${DOTFILES_UTIL_SCRIPT}"

log_info "Starting dotfiles installation..."

debug_system

USER="${USER:-$(whoami)}"
DISTRO=${1:-}
if [[ -z "$DISTRO" ]]; then
    log_error "Please provide the distribution as the first argument."
    exit 1
fi

# *******************************
# ** Package manager detection **
# *******************************

PKG_MANAGER=""
COMMON_PKGS=("$(jq -r '.common_packages[]' "${DOTFILES_CONFIG_PATH}")")
if [[ ${#COMMON_PKGS[@]} -eq 0 ]]; then
    log_error "No common packages found in the config file."
    exit 1
fi
DISTRO_PKGS=("$(jq -re ".distro_packages.""${DISTRO}"[]"" "${DOTFILES_CONFIG_PATH}")")

log_info "Detecting package manager (distro: ${DISTRO})..."
for manager in $(jq -r '.pkg_managers | keys[]' "${DOTFILES_CONFIG_PATH}"); do
    if command -v "${manager}" >/dev/null 2>&1; then
        PKG_MANAGER="${manager}"
        echo "OK. Detected package manager: ${PKG_MANAGER}"
        break
    else
        echo "${manager} is not available"
    fi
done
if [[ -z "$PKG_MANAGER" ]]; then
    log_error "No package manager found."
    exit 1
fi
INSTALL_CMD=$(jq -re ".pkg_managers[\"${PKG_MANAGER}\"] | .install_cmd" "$DOTFILES_CONFIG_PATH")
UPDATE_CMD=$(jq -re ".pkg_managers[\"${PKG_MANAGER}\"] | .update_cmd" "$DOTFILES_CONFIG_PATH")
PRE_INSTALL_CMDS=$(jq -r ".pkg_managers[\"${PKG_MANAGER}\"] | .pre_install_commands[]?" "$DOTFILES_CONFIG_PATH")
POST_INSTALL_CMDS=$(jq -r ".pkg_managers[\"${PKG_MANAGER}\"] | .post_install_commands[]?" "$DOTFILES_CONFIG_PATH")
if [[ ${CI} != "true" ]]; then
    update_path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
fi

# *******************
# ** Configuration **
# *******************

# Paths
ZSHRC="$HOME/.zshrc"
TMUX_CONF="$HOME/.tmux.conf"
# Neovim
NVIM_CONFIG_DIR="${NVIM_CONFIG_DIR:-}"
NVIM_SCRIPTS_DIR="${NVIM_SCRIPTS_DIR:-}"
NVIM_OPTIONS_FILE="${NVIM_OPTIONS_FILE:-}"
NVIM_LANGUAGE_SCRIPT_DIR="${NVIM_LANGUAGE_SCRIPT_DIR:-}"
for v in NVIM_CONFIG_DIR NVIM_SCRIPTS_DIR NVIM_OPTIONS_FILE NVIM_LANGUAGE_SCRIPT_DIR; do
    if [[ -z "${!v}" ]]; then
        log_error "Variable ${v} is not set."
        exit 1
    fi
done

# User files
ZSH_LOCAL="$HOME/.zsh_local"
PROFILE="$HOME/.profile"
for file in "$ZSH_LOCAL" "$PROFILE"; do
    if [[ ! -f "$file" ]]; then
        touch "$file"
        if [[ "$DISTRO" == "macos" ]]; then
            run_sudo_cmd "chown ${USER}:staff ${file}"
        else
            run_sudo_cmd "chown ${USER}:${USER} ${file}"
        fi
    fi
done

# Options
TERM_COLOR="$(jq -r '.term_color' "$DOTFILES_CONFIG_PATH")"
if [[ -z "$TERM_COLOR" || "$TERM_COLOR" == "null" ]]; then
    TERM_COLOR="xterm-256color"
fi
OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT="$(jq -r '.oh_my_zsh_custom_theme_repo' "$DOTFILES_CONFIG_PATH")"
if [[ -z "$OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT" || "$OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT" == "null" ]]; then
    OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT="romkatv/powerlevel10k"
fi
OH_MY_ZSH_CUSTOM_THEME_REPO=$OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT
OH_MY_ZSH_CUSTOM_THEME_REPO=$OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT

# Fonts
FONT_NAME="$(jq -r '.font_name' "$DOTFILES_CONFIG_PATH")"
FONT_MESLOLGS_NF="MesloLGS NF"
if [[ -z "$FONT_NAME" || "$FONT_NAME" == "null" ]]; then
    FONT_NAME="$FONT_MESLOLGS_NF"
fi
FONT_URL="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20"

# Relative paths
while IFS= read -r line; do
    relative_paths+=("$line")
done < <(jq -r '.relative_paths[]' "$DOTFILES_CONFIG_PATH")

# Oh-my-zsh plugins
# Example:
# {"key":"zsh-syntax-highlighting","value":"https://github.com/zsh-users/zsh-syntax-highlighting.git"}
# {"key":"zsh-autosuggestions","value":"https://github.com/zsh-users/zsh-autosuggestions.git"}
# {"key":"zsh-history-substring-search","value":"https://github.com/zsh-users/zsh-history-substring-search.git"}
OHMYZSH_PLUGIN_DATA=$(jq -c '.ohmyzsh_plugins | to_entries[]' "$DOTFILES_CONFIG_PATH")

# Tmux plugins
# Example:
# {"key":"tpm","value":"https://github.com/tmux-plugins/tpm.git"}
# {"key":"dracula","value":"https://github.com/dracula/tmux.git"}
TMUX_PLUGIN_DATA=$(jq -c '.tmux_plugins | to_entries[]' "$DOTFILES_CONFIG_PATH")

# Load the fonts dictionary from the fonts.json file
font_names=()
font_urls=()
while IFS=":" read -r key value; do
    font_names+=("$key")
    font_urls+=("$value")
done < <(jq -r 'to_entries|map("\(.key):\(.value|tostring)")|.[]' "$DOTFILES_FONTS_PATH")

# ****************************
# ** Argument parsing logic **
# ****************************

# Parse command-line options
# -r: oh-my-zsh theme repository
# -f: font name
while getopts "r:f:" opt; do
    case ${opt} in
    r)
        OH_MY_ZSH_CUSTOM_THEME_REPO="$OPTARG"
        ;;
    f)
        FONT_NAME="$OPTARG"
        if [[ "$FONT_NAME" == "${FONT_MESLOLGS_NF}" ]] || printf '%s\n' "${font_names[@]}" | grep -q -F "$FONT_NAME"; then
            if [[ "$FONT_NAME" != "${FONT_MESLOLGS_NF}" ]]; then
                FONT_INDEX=$(printf '%s\n' "${font_names[@]}" | grep -n -F "$FONT_NAME" | cut -d: -f1)
                FONT_URL=${font_urls[$((FONT_INDEX - 1))]}
            fi
        else
            log_error "Invalid font name: $FONT_NAME. Please provide a valid font name."
            exit 1
        fi
        ;;
    \?)
        log_error "Invalid option: -$OPTARG"
        exit 1
        ;;
    esac
done

# ***********************
# ** Debug information **
# ***********************

log_config() {
    # shellcheck disable=SC2155
    local is_terminal=$(tput colors 2>/dev/null)
    local color_green=""
    local color_yellow=""
    local color_none="" # No Color
    if [ -n "$is_terminal" ]; then
        color_green=$(tput setaf 2)  # Green
        color_yellow=$(tput setaf 3) # Yellow
        color_none=$(tput sgr0)      # Reset
    fi
    local hyphens
    hyphens=$(printf '%*s' 80 '' | tr ' ' '-')

    cat <<EOF

${color_green}[CONFIGURATION]${color_none}
${hyphens}
${color_yellow}User:${color_none} ${USER}
${color_yellow}Distribution:${color_none} ${DISTRO}
${color_yellow}Package manager:${color_none} ${PKG_MANAGER}
${color_yellow}Install command:${color_none} ${INSTALL_CMD}
${color_yellow}Update command:${color_none} ${UPDATE_CMD}
${color_yellow}Pre-install commands:${color_none} ${PRE_INSTALL_CMDS}
${color_yellow}Post-install commands:${color_none} ${POST_INSTALL_CMDS}
${hyphens}
${color_yellow}Paths:${color_none}
    ZSHRC: ${ZSHRC}
    NVIM_CONFIG_DIR: ${NVIM_CONFIG_DIR}
    NVIM_SCRIPTS_DIR: ${NVIM_SCRIPTS_DIR}
    NVIM_OPTIONS_FILE: ${NVIM_OPTIONS_FILE}
    NVIM_LANGUAGE_SCRIPT_DIR: ${NVIM_LANGUAGE_SCRIPT_DIR}
${hyphens}
${color_yellow}Configuration file:${color_none} ${DOTFILES_CONFIG_PATH}
${color_yellow}Font file:${color_none} ${DOTFILES_FONTS_PATH}
${hyphens}
${color_yellow}Options:${color_none}
    OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT: ${OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT}
    OH_MY_ZSH_CUSTOM_THEME_REPO: ${OH_MY_ZSH_CUSTOM_THEME_REPO}
    FONT_NAME: ${FONT_NAME}
    FONT_URL: ${FONT_URL}
${hyphens}
${color_yellow}Relative paths:${color_none} ${relative_paths[*]}
${hyphens}
${color_yellow}Oh My ZSH Plugins:${color_none}
${OHMYZSH_PLUGIN_DATA}
${hyphens}
${color_yellow}Tmux plugins:${color_none}
${TMUX_PLUGIN_DATA}
${hyphens}
${color_yellow}Terminal color:${color_none} ${TERM_COLOR}
${hyphens}
${color_yellow}Common packages:${color_none} ${COMMON_PKGS[*]}
${color_yellow}Distro-specific packages:${color_none} ${DISTRO_PKGS[*]}
${hyphens}

EOF
}

# ******************
# ** Source Zshrc **
# ******************

source_zshrc() {
    log_info "Sourcing .zshrc file"
    # Fix permissions before sourcing the .zshrc file
    zsh -c "export ZSH_DISABLE_COMPFIX=true; source ${ZSHRC}"
}

# **********************
# ** Install Packages **
# **********************

install_packages() {
    log_info "Installing packages (package manager: ${PKG_MANAGER}, DISTRO: ${DISTRO})..."

    # Update the package manager
    echo ":: Updating the package manager (via ${UPDATE_CMD})..."
    run_sudo_cmd "$UPDATE_CMD"
    echo "OK. Package manager updated."

    # Call pre-install commands
    echo ":: Running pre-install commands..."
    if [[ -n "${PRE_INSTALL_CMDS}" ]]; then
        echo "Pre-install commands: ${PRE_INSTALL_CMDS}"
        for cmd in "${PRE_INSTALL_CMDS[@]}"; do
            run_sudo_cmd "${cmd}"
        done
    fi
    echo "OK. Pre-install commands executed."
    local packages_json=""
    local packages_str=""
    packages_json=$(printf '%s\n' "${COMMON_PKGS[@]}" "${DISTRO_PKGS[@]}" | jq -R . | jq -s .) # Convert bash arrays to JSON arrays
    packages_str=$(jq -rj '.[] | . + " "' <<<"$packages_json")                                 # Convert the JSON array to a string
    packages_str=${packages_str%" "}                                                           # Remove trailing space

    echo ":: Running the package manager install command..."
    echo "Packages: ${packages_str}"
    case $PKG_MANAGER in
    "brew")
        if [[ "${CI}" == "true" ]]; then
            run_sudo_cmd "HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1 ${INSTALL_CMD} ${packages_str}"
        else
            run_sudo_cmd "${INSTALL_CMD} ${packages_str}"
        fi
        ;;
    *) run_sudo_cmd "${INSTALL_CMD} ${packages_str}" ;;
    esac
    echo "OK. Packages installed."

    # Call post-install commands
    echo ":: Running post-install commands..."
    if [[ -n "${POST_INSTALL_CMDS}" ]]; then
        echo "Post-install commands: ${POST_INSTALL_CMDS}"
        for cmd in "${POST_INSTALL_CMDS[@]}"; do
            run_sudo_cmd "${cmd}"
        done
    fi
    echo "OK. Post-install commands executed."

    log_success "Packages installed successfully!"
}

# ********************
# ** Install Neovim **
# ********************

install_neovim() {
    log_info "Installing Neovim on ${PKG_MANAGER}..."

    # Determine package manager and corresponding commands
    case "${PKG_MANAGER}" in
    "apt-get")
        # Check if Neovim is already installed
        if ! dpkg -s neovim &>/dev/null; then

            # Neovim variables
            local nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
            local nvim_tarball_name="nvim-linux64.tar.gz"
            local nvim_install_dir="/opt/nvim-linux64"
            local nvim_bin_dir="$nvim_install_dir/bin"

            # Create a temporary directory
            local nvim_tmpdir
            nvim_tmpdir=$(mktemp -d)
            # Download the pre-built binary for Neovim into the temporary directory
            curl -L $nvim_url -o "$nvim_tmpdir/$nvim_tarball_name"
            # Extract the downloaded archive in the temporary directory
            tar -C "$nvim_tmpdir" -xzf "$nvim_tmpdir/$nvim_tarball_name"
            # Remove the existing directory if it exists
            if [ -d "$nvim_install_dir" ]; then
                run_sudo_cmd "rm -r $nvim_install_dir"
            fi
            # Move the extracted directory to /opt
            run_sudo_cmd "mv $nvim_tmpdir/nvim-linux64 $nvim_install_dir"
            # Remove the temporary directory
            rm -r "$nvim_tmpdir"
            # Add the Neovim binary directory to the PATH in .zshenv
            update_zsh_local "${ZSH_LOCAL}" "export PATH=\"\$PATH:$nvim_bin_dir\""
            update_path "$nvim_bin_dir"
            # Install tree-sitter
            echo "Installing tree-sitter..."

            # Create a temporary directory
            local ts_tmpdir
            ts_tmpdir=$(mktemp -d)
            # TS variables
            local ts_binary_name="tree-sitter-linux-x64"
            local ts_binary_url="https://github.com/tree-sitter/tree-sitter/releases/latest/download/$ts_binary_name.gz"
            # TS file paths
            local ts_gz_file_path="$ts_tmpdir/$ts_binary_name.gz"
            local ts_binary_file_path="$ts_tmpdir/$ts_binary_name"

            # Download the precompiled binary for tree-sitter
            curl -L $ts_binary_url -o "$ts_gz_file_path"
            # Extract the downloaded archive to the temporary directory
            gunzip "$ts_gz_file_path"
            # Make the binary executable
            chmod +x "$ts_binary_file_path"
            # Move the binary to /usr/local/bin
            run_sudo_cmd "mv $ts_binary_file_path /usr/local/bin/tree-sitter"
            # Remove the temporary directory
            rm -r "$ts_tmpdir"

        else
            log_info "Neovim is already installed"
        fi
        ;;
    *) run_sudo_cmd "${INSTALL_CMD} neovim" ;;
    esac

    source_zshrc
    log_success "Neovim installed successfully!"
}

install_neovim_deps() {
    log_info "Installing Neovim dependencies..."

    # Create the directory for virtual environments
    update_zsh_local "${ZSH_LOCAL}" "export VENVS_DIR=${VENVS_DIR_ESCAPED}"
    export VENVS_DIR
    VENVS_DIR=$(eval echo "${VENVS_DIR_ESCAPED}")

    # Nvim virtual environment
    update_zsh_local "${ZSH_LOCAL}" "export NVIM_VENV=${NVIM_VENV_DIR_ESCAPED}"
    export NVIM_VENV
    NVIM_VENV=$(eval echo "${NVIM_VENV_DIR_ESCAPED}")

    # Get the Python command
    local PYTHON_CMD=""
    PYTHON_CMD=$(command -v python3 || command -v python)
    if [[ -z "${PYTHON_CMD}" ]]; then
        log_error "Python is not installed. Please install Python and run this script again."
        exit 1
    fi
    local python_venv_activate="${NVIM_VENV}/bin/activate"
    if [[ ! -f "${python_venv_activate}" ]]; then
        log_info "Creating virtual environment for Neovim..."
        mkdir -p "${NVIM_VENV}"
        "${PYTHON_CMD}" -m venv "${NVIM_VENV}"
        log_success "OK. Virtual environment created successfully!"
    fi

    local node_packages
    local pip_packages
    node_packages=$(jq -r '.nvim_deps.node_packages[]' "${DOTFILES_CONFIG_PATH}")
    pip_packages=$(jq -r '.nvim_deps.pip_packages[]' "${DOTFILES_CONFIG_PATH}")

    # Install the node packages
    if [[ -n "${node_packages}" ]]; then
        log_info "Installing node packages: ${node_packages}"
        local node_deps_installed=false
        for node_pkg_manager in npm yarn pnpm; do
            if command -v "${node_pkg_manager}" &>/dev/null; then
                log_info "Using ${node_pkg_manager} to install node packages..."
                local node_pkg_manager_path
                node_pkg_manager_path=$(command -v "${node_pkg_manager}")
                run_sudo_cmd "${UPDATE_CMD}"
                case "${node_pkg_manager}" in
                "npm")
                    run_sudo_cmd "${node_pkg_manager_path} install -g ${node_packages}"
                    ;;
                "yarn")
                    run_sudo_cmd "${node_pkg_manager_path} global add ${node_packages}"
                    ;;
                "pnpm")
                    run_sudo_cmd "${node_pkg_manager_path} add -g ${node_packages}"
                    ;;
                esac
                node_deps_installed=true
                break
            fi
        done
        if ! ${node_deps_installed}; then
            log_error "No package manager found to install node packages. Please install npm, yarn, or pnpm and run this script again."
            exit 1
        fi
        log_success "OK. Node packages installed successfully!"
    fi

    # Install the pip packages
    if [[ -n "${pip_packages}" ]]; then
        log_info "Installing pip packages: ${pip_packages}"
        echo "Activating the virtual environment..."
        # shellcheck disable=SC1090
        source "${python_venv_activate}"
        local PIP_CMD=""
        PIP_CMD=$(command -v pip3 || command -v pip)
        if [[ -z "${PIP_CMD}" ]]; then
            log_error "pip is not installed. Please install pip and run this script again."
            deactivate
            exit 1
        fi
        "${PIP_CMD}" install --upgrade pip && "${PIP_CMD}" install "${pip_packages}"
        log_success "OK. Pip packages installed successfully!"
        deactivate
        echo "Deactivated the virtual environment."
    fi

    log_success "OK. Neovim dependencies installed successfully!"
}

# **********************
# ** Configure Neovim **
# **********************

configure_neovim() {
    # Define local variables
    log_info "Configuring Neovim (package manager: $PKG_MANAGER)..."

    # Parse variables from config.json
    local nvim_profiles_data
    nvim_profiles_data=$(jq -rS '.nvim_profiles' "${DOTFILES_CONFIG_PATH}")
    local nvim_profiles
    nvim_profiles=$(jq -r 'keys[]' <<<"${nvim_profiles_data}")
    if [[ -z "${nvim_profiles}" ]]; then
        log_error "No Neovim profiles found in the config file. Please check the ${DOTFILES_CONFIG_PATH} file and ensure the profiles are defined."
        exit 1
    fi
    # Run the Neovim headless commands
    nvim --headless -c "Lazy sync" -c "MasonUpdate" -c "quitall"
    for profile in ${nvim_profiles}; do
        local profile_data
        profile_data=$(jq -r ".${profile}" <<<"${nvim_profiles_data}")
        local checks_required
        local checks_one_of
        local custom_script
        checks_required=$(echo "${profile_data}" | jq -r 'try (.checks.required[]) // empty')
        checks_one_of=$(echo "${profile_data}" | jq -r '.checks.one_of[]?')
        custom_script=$(echo "${profile_data}" | jq -r '.custom_script?')
        # debug info
        log_info "Configuring Neovim profile: ${profile}..."
        log_info "Required checks: ${checks_required[*]}"
        log_info "One-of checks: ${checks_one_of[*]}"
        log_info "Custom script(null if not set): $custom_script"

        # Check required
        if [[ -z "${checks_required}" ]]; then
            log_info "No required checks found for Neovim profile ${profile}. Please check the ${DOTFILES_CONFIG_PATH} file and ensure the checks are defined."
            continue
        else
            log_info "Checking required checks for Neovim profile ${profile}. Required checks: ${checks_required}"
            for check in ${checks_required}; do
                if [[ "$check" =~ ^(python|typescript|bash)$ ]]; then
                    # Already checked...
                    :
                elif ! command -v "$check" &>/dev/null; then
                    log_warn "$check is required for Neovim profile ${profile}. Please install it and run this script again. Skipping..."
                    continue 2
                fi
                echo -e "\nOK. Required check ${check} exists."
            done
        fi

        # Check one of
        if [[ -z "${checks_one_of}" ]]; then
            echo "OK. No one-of checks found for Neovim profile ${profile}."
        else
            log_info "Checking one-of checks for Neovim profile ${profile}. One-of checks: ${checks_one_of}"
            local one_of_exists=false
            for check in ${checks_one_of}; do
                echo "Checking one of ${check}..."
                if command -v "${check}" &>/dev/null; then
                    one_of_exists=true
                    echo "OK. One of ${check} exists."
                    break
                fi
            done
            if ! ${one_of_exists}; then
                log_warn "One-of ${checks_one_of} is required for Neovim profile ${profile}. Please install one of them and run this script again. Skipping..."
                continue
            fi
        fi

        # Build the TSInstallSync and MasonInstall commands for the profile
        local keys=("parsers" "lsps" "daps" "linters" "formatters")
        local mason_deps=()
        local parsers=()
        for key in "${keys[@]}"; do
            local items
            items=$(echo "${profile_data}" | jq -r ".${key}[]? | @sh" | tr -d "'")
            if [[ "${key}" == "parsers" && -n "${items}" ]]; then
                IFS=$'\n' parsers=("$items")
            else
                IFS=$'\n' mason_deps+=("$items")
            fi
        done
        log_info "Profile ${profile} configuration:"
        log_info "Parsers: ${parsers[*]}"
        log_info "Mason dependencies: ${mason_deps[*]}"
        # Profile commands
        local commands=()
        if [[ -n "${parsers[*]}" ]]; then
            commands+=("TSInstallSync! ${parsers[@]}")
        fi
        if [[ -n "${mason_deps[*]}" ]]; then
            local mason_install_command="MasonInstall"
            for dep in "${mason_deps[@]}"; do
                mason_install_command+=" ${dep}"
            done
            mason_install_command+=" --force"
            mason_install_command=$(echo "${mason_install_command}" | tr -d "'")
            commands+=("${mason_install_command}")
        fi
        for cmd in "${commands[@]}"; do
            {
                log_info "Running command: ${cmd}..."
                if [ "${DISTRO}" != "macos" ]; then
                    # Fix permissions for npm cache
                    run_sudo_cmd "chown -R ${USER}:${USER} ${HOME}/.npm-cache"
                    npm config set cache "${HOME}/.npm-cache"
                fi
                if [[ "$CI" == "true" ]]; then
                    log_info "Skipping headless commands."
                else
                    cmd=$(echo "${cmd}" | tr '\n' ' ') # Clean up the command
                    nvim --headless -c "${cmd}" -c "quitall"
                fi
            } &
        done
        wait

        # Run custom script
        if [[ "${custom_script}" != "null" ]]; then
            local script="${NVIM_LANGUAGE_SCRIPT_DIR}/${custom_script}"
            if [[ -f "$script" ]]; then
                log_info "Custom script found: ${script}. Running script..."
                # Usage: <script> <package_manager> <zsh_local>
                # shellcheck disable=SC1090
                source "${script}" "${PKG_MANAGER}" "${ZSH_LOCAL}"
                echo "OK. Custom script ${script} executed successfully."
            else
                log_error "Invalid custom script: ${script}. Please check the ${DOTFILES_CONFIG_PATH} file and ensure the script exists in ${NVIM_LANGUAGE_SCRIPT_DIR}."
                exit 1
            fi
        fi
    done

    source_zshrc
    log_success "Neovim configured successfully!"
}

# *********************
# ** Create symlinks **
# *********************

create_symlink() {
    local src=$1
    local target=$2
    log_info "Creating symlink from ${src} to ${target}"
    mkdir -p "$(dirname "$target")" # Ensure the parent directory exists
    # If the target is a directory, remove it
    if [ -d "$target" ]; then
        rm -rf "$target"
    fi
    ln -sf "$src" "$target"
    echo "OK. Symlink created successfully!"
}

# *******************
# ** Install fonts **
# *******************

install_fonts() {
    log_info "Installing ${FONT_NAME} fonts..."

    # Determine the OS and set the font directory accordingly
    local font_dir
    case "$(uname)" in
    *nix | *ux)
        font_dir=~/.fonts
        ;;
    Darwin)
        font_dir=~/Library/Fonts
        ;;
    *)
        log_error "Unsupported OS for font installation"
        exit 1
        ;;
    esac

    # Check if the fonts are already installed
    if [[ -d "$font_dir" && -n "$(ls -A "$font_dir")" ]]; then
        log_info "${FONT_NAME} fonts are already installed."
        return
    fi

    # Create a temporary directory
    tmp_dir=$(mktemp -d)

    # Check if the font starts with MesloLG and OH_MY_ZSH_CUSTOM_THEME_REPO equals OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT
    local font_files=()
    if [[ "$FONT_NAME" = MesloLG* ]] && [[ "$OH_MY_ZSH_CUSTOM_THEME_REPO" = "$OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT" ]]; then
        # See https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#fonts
        # Download the font files in parallel
        for font_file in "Regular" "Bold" "Italic" "Bold Italic"; do
            (
                # Replace spaces in font_file with %20 for the URL
                local url_font_file=${font_file// /%20}
                log_info "Downloading MesloLGS NF ${font_file}.ttf..."
                curl -sSLo "$tmp_dir/MesloLGS NF $font_file.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20${url_font_file}.ttf"
                # Add the full path to the downloaded file to the array
                font_files+=("$tmp_dir/MesloLGS NF $font_file.ttf")
                echo "OK. MesloLGS NF ${font_file}.ttf downloaded successfully."
            ) &
        done
        wait # Wait for all background tasks to finish
    else
        # Download the font file from the URL
        log_info "Downloading ${FONT_NAME} font..."
        curl -sSLo "$tmp_dir/font.zip" "$FONT_URL"

        # Unzip the font file
        unzip -q "$tmp_dir/font.zip" -d "$tmp_dir"
        font_files=("$tmp_dir"/*.ttf)
    fi

    # Create the font directory if it doesn't exist
    mkdir -p "$font_dir"

    # Move the font files to the correct directory
    for font_file in "${font_files[@]}"; do
        mv "$font_file" "$font_dir"
    done

    # Update the font cache for Linux
    [[ "$(uname)" == *nix || "$(uname)" == *ux ]] && fc-cache -fv

    # Remove the temporary directory
    rm -r "$tmp_dir"

    log_success "${FONT_NAME} fonts installed successfully!"
}

# *******************************
# ** Install zsh and oh-my-zsh **
# *******************************
install_zsh_and_oh_my_zsh() {
    # Check if zsh is installed
    local zsh_installed=false
    local oh_my_zsh_installed=false
    local oh_my_zsh_dir="$HOME"/.oh-my-zsh
    log_info "Checking if zsh is installed..."
    if [ -n "$(command -v zsh)" ]; then
        echo "zsh is installed"
        zsh_installed=true

        # Check if oh-my-zsh.sh is present
        if [ -f "$oh_my_zsh_dir"/oh-my-zsh.sh ]; then
            echo "oh-my-zsh is already installed"
            oh_my_zsh_installed=true

            # Check if oh-my-zsh is a git repository
            if [ -d "$oh_my_zsh_dir/.git" ]; then
                echo "oh-my-zsh directory is a git repository. Stashing local changes and pulling latest changes..."
                git -C "$oh_my_zsh_dir" stash
                git -C "$oh_my_zsh_dir" pull --rebase=false
                if [ "$(git -C "$oh_my_zsh_dir" stash list)" ]; then
                    git -C "$oh_my_zsh_dir" stash apply
                fi
            fi
        else
            # Backup existing oh-my-zsh installation if it exists
            if [ -d "$oh_my_zsh_dir" ]; then
                echo "Backing up existing oh-my-zsh installation..."
                mv "$oh_my_zsh_dir" "$oh_my_zsh_dir".bak
            fi

            # Install oh-my-zsh
            echo "Installing oh-my-zsh..."
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            oh_my_zsh_installed=true
        fi
    fi

    # If either zsh or oh-my-zsh are not installed, exit the script
    if [ "$zsh_installed" = false ] || [ "$oh_my_zsh_installed" = false ]; then
        log_error "Either zsh or oh-my-zsh is not installed, cannot source .zshrc file"
        exit 1
    fi
}

# *********************
# ** Create symlinks **
# *********************

create_symlinks() {
    # Create symlinks for all files in the relative_paths array
    for relative_path in "${relative_paths[@]}"; do
        local src="${DOTFILES_DIR}/${relative_path}"
        local target="$HOME/$relative_path"
        create_symlink "$src" "$target"
    done
}

# ***************************************
# ** Clone oh-my-zsh plugins and theme **
# ***************************************

clone_plugins_and_themes() {
    log_info "Cloning oh-my-zsh plugins and theme..."
    while IFS= read -r plugin; do
        (
            local name
            local url
            name=$(echo "${plugin}" | jq -r '.key')
            url=$(echo "${plugin}" | jq -r '.value')
            local dir="$HOME/.oh-my-zsh/custom/plugins/$name"
            log_info "Checking $dir..."
            mkdir -p "$dir" # Ensure the directory exists
            if [ -d "$dir/.git" ]; then
                echo "Directory $dir already exists. Stashing local changes and pulling latest changes..."
                git -C "$dir" stash
                git -C "$dir" pull --rebase=false
                if [ "$(git -C "$dir" stash list)" ]; then
                    git -C "$dir" stash apply
                fi
            else
                echo "Cloning $url into $dir..."
                git clone --depth=1 "$url" "$dir"
            fi
            echo "OK. $plugin cloned successfully."
        ) &
    done <<<"${OHMYZSH_PLUGIN_DATA}"
    wait # Wait for all background tasks to finish

    log_success "OK. Oh-my-zsh plugins and theme cloned successfully!"
}

# ************************
# ** Clone tmux plugins **
# ************************

clone_tmux_plugins() {
    log_info "Cloning tmux plugins..."
    while IFS= read -r plugin; do
        (
            local name
            local url
            name=$(echo "${plugin}" | jq -r '.key')
            url=$(echo "${plugin}" | jq -r '.value')
            local dir="$HOME/.tmux/plugins/$name"
            log_info "Checking $dir..."
            mkdir -p "$dir" # Ensure the directory exists
            if [ -d "$dir/.git" ]; then
                echo "Directory $dir already exists. Stashing local changes and pulling latest changes..."
                git -C "$dir" stash
                git -C "$dir" pull --rebase=false
                if [ "$(git -C "$dir" stash list)" ]; then
                    git -C "$dir" stash apply
                fi
            else
                echo "Cloning $url into $dir..."
                git clone --depth=1 "$url" "$dir"
            fi
            echo "OK. $plugin cloned successfully."
        ) &
    done <<<"${TMUX_PLUGIN_DATA}"
    wait # Wait for all background tasks to finish

    log_success "OK. Tmux plugins cloned successfully!"

}

# **************************
# ** Install tmux plugins **
# **************************

install_tmux_plugins() {
    # Ensure tpm is installed
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    if [[ -d "$tpm_dir" ]]; then
        log_info "Tmux Plugin Manager found. Updating..."
        git -C "$tpm_dir" stash
        git -C "$tpm_dir" pull --rebase=false
        if [ "$(git -C "$tpm_dir" stash list)" ]; then
            git -C "$tpm_dir" stash apply
        fi
    else
        log_info "Tmux Plugin Manager not found. Cloning..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    fi

    # Install tmux plugins
    log_info "Installing tmux plugins..."
    local session_name
    session_name="temp_$(date +%s)"
    if tmux new-session -d -s "$session_name"; then
        if ! tmux source-file "$TMUX_CONF"; then
            log_error "Failed to source .tmux.conf"
        fi
        if ! "$tpm_dir/bin/install_plugins"; then
            log_error "Failed to install tmux plugins"
        fi
        tmux kill-session -t "$session_name"
    else
        log_error "Failed to create new tmux session"
    fi
    update_zsh_local "${ZSH_LOCAL}" "export TERM=\"$TERM_COLOR\""
}

# *********************
# ** Generate locale **
# *********************

generate_locale() {
    local lang=$1
    local encoding=$2
    local locale_line="${lang}.${encoding} ${encoding}"
    local locale_gen_file="/etc/locale.gen"
    if ! grep -q "^$locale_line" "$locale_gen_file"; then
        echo "$locale_line" | run_sudo_cmd "tee -a $locale_gen_file"
    fi

    if type locale-gen &>/dev/null; then
        echo "Running locale-gen..."
        run_sudo_cmd "locale-gen"
    elif type localedef &>/dev/null; then
        echo "Running localedef..."
        run_sudo_cmd "localedef -i $lang -f $encoding $lang.$encoding"
    fi
}

# **********************
# ** Configure Docker **
# **********************

configure_docker() {
    # Docker specific configuration
    if [ -f /.dockerenv ]; then
        log_info "Docker detected. Configuring environment for Docker..."
        # Set the language environment variables
        local language="en_US"
        local character_encoding="UTF-8"
        update_zsh_local "${ZSH_LOCAL}" "export LANG=C.${character_encoding}"
        update_zsh_local "${ZSH_LOCAL}" "export LC_ALL=${language}.${character_encoding}"

        case "$(uname)" in
        "Darwin")
            # MacOS specific configuration
            echo "Running defaults write..."
            defaults write -g AppleLocale -string "$language"
            return 0
            ;;
        *)
            # Generate locale
            log_info "Generating locale..."
            # If neither locale-gen nor localedef is available, exit the script
            if ! type locale-gen &>/dev/null && ! type localedef &>/dev/null; then
                log_error "No supported method for generating locale found"
                exit 1
            fi
            generate_locale $language $character_encoding
            ;;
        esac
    fi
}

# *****************************
# ** Install oh-my-zsh theme **
# *****************************

install_oh_my_zsh_theme() {
    local oh_my_zsh_theme_name=""
    if command -v basename &>/dev/null; then
        oh_my_zsh_theme_name=$(basename "${OH_MY_ZSH_CUSTOM_THEME_REPO}")
    else
        # Use parameter expansion as a fallback
        oh_my_zsh_theme_name=${OH_MY_ZSH_CUSTOM_THEME_REPO##*/}
    fi
    if [[ -z "$oh_my_zsh_theme_name" ]]; then
        log_error "Failed to extract theme name from $OH_MY_ZSH_CUSTOM_THEME_REPO"
        exit 1
    fi
    local theme_dir="${HOME}/.oh-my-zsh/custom/themes/${oh_my_zsh_theme_name}"
    if [[ ! -d "${theme_dir}" ]]; then
        log_info "Installing ${oh_my_zsh_theme_name} theme..."
        git clone --depth=1 https://github.com/"${OH_MY_ZSH_CUSTOM_THEME_REPO}".git "${theme_dir}"
    else
        log_info "${oh_my_zsh_theme_name} theme is already installed. Pulling latest changes..."
        git -C "${theme_dir}" stash
        git -C "${theme_dir}" pull --rebase=false
        if [ "$(git -C "${theme_dir}" stash list)" ]; then
            git -C "${theme_dir}" stash apply
        fi
    fi
    echo "OK. Theme installed successfully."
}

# ***************************
# ** Configure permissions **
# ***************************

configure_permissions() {
    log_info "Configuring permissions for user ${USER}..."
    local dirs=(
        "/home/${USER}/"{.local,.cache,.npm,.npm-cache,.config}
    )
    for dir in "${dirs[@]}"; do
        if [ ! -d "${dir}" ]; then
            run_sudo_cmd "mkdir -p ${dir}"
        fi
        run_sudo_cmd "chown -R ${USER}:${USER} ${dir}"
    done
    echo "OK. Permissions configured for user ${USER}."
}

# **********
# ** Main **
# **********

main() {
    log_info "🚀 Starting dotfiles installation (distro: ${DISTRO})..."
    log_config
    if [ "${DISTRO}" != "macos" ]; then
        configure_permissions
    fi

    # Install zsh and oh-my-zsh
    install_zsh_and_oh_my_zsh

    # Create symlinks
    create_symlinks

    # Detect and install packages
    install_packages

    # Clone plugins and themes
    clone_plugins_and_themes

    # Clone tmux plugins
    clone_tmux_plugins

    # Install tmux plugins
    install_tmux_plugins

    # Docker specific configuration
    configure_docker

    # Install oh-my-zsh theme
    install_oh_my_zsh_theme

    # Install fonts
    install_fonts
    source_zshrc

    # Install Neovim
    install_neovim
    install_neovim_deps

    # Configure Neovim
    configure_neovim

    # Finish
    log_success "✅ Dotfiles installation complete!"
}

main

#!/bin/bash
# 
# This script installs the dotfiles on your system.
# It checks and installs zsh and oh-my-zsh, creates symbolic links for files from the repository to the home directory,
# determines the current shell (exits if not bash or zsh), identifies the package manager and installs packages,
# clones oh-my-zsh plugins and theme, installs oh-my-zsh theme, installs fonts, sources .zshrc file,
# parses config.json for Neovim configuration and applies it, and installs and configures Neovim.
# 
# Usage: ./install.sh
# 
# Dependencies: zsh, oh-my-zsh, jq, ps
# 
set -e

# Initialization
# shellcheck disable=SC1091
source "init.sh" 

# Source the run_sudo_cmd function
. scripts/run_sudo_cmd.sh

log_info "Starting dotfiles installation..."

# *******************
# ** Configuration **
# *******************

# Paths
ZSHRC="$HOME/.zshrc"
TMUX_CONF="$HOME/.tmux.conf"
NVIM_CONFIG_DIR="$DOTFILES_DIR/.config/nvim"
NVIM_SCRIPTS_DIR="${NVIM_CONFIG_DIR}/scripts"
NVIM_OPTIONS_FILE="${NVIM_CONFIG_DIR}/lua/core/options.lua"
CLIPBOARD_CONFIG_SCRIPT="${NVIM_SCRIPTS_DIR}/clipboard.sh"
NVIM_LANGUAGE_SCRIPT_DIR="${NVIM_SCRIPTS_DIR}/lang"

# Configuration file
CONFIG_FILE="$DOTFILES_CONIG_DIR/config.json"

# This function parses a JSON object and stores the keys and values in separate arrays.
# It takes three arguments:
#   - A JSON key
#   - The name of the array to store the keys
#   - The name of the array to store the values
parse_json_object() {
    # Store the arguments in local variables
    local json_key="$1"
    local keys_array_name="$2"
    local values_array_name="$3"

    # Initialize arrays to hold the keys and values
    local keys=()
    local values=()

    # Extract the JSON object associated with the key from the global json_data variable
    local json_object
    json_object=$(jq -r ".$json_key" "$CONFIG_FILE")

    # Loop over the keys in the JSON object
    while IFS=$'\n' read -r key; do
        # Add the key to the keys array
        keys+=("$key")
        # Use jq to extract the value corresponding to the key from the JSON object
        # Add the value to the values array
        values+=("$(jq -r ".\"$key\"" <<< "$json_object")")
    done < <(jq -r 'keys[]' <<< "$json_object")  # Use jq to extract the keys from the JSON object

    # Use eval to assign the keys and values to the arrays specified by keys_array_name and values_array_name
    # The \${keys[@]} and \${values[@]} syntaxes are used to expand the arrays into a list of quoted elements
    eval "$keys_array_name=(\"\${keys[@]}\")"
    eval "$values_array_name=(\"\${values[@]}\")"
}

# Options
TERM_COLOR="$(jq -r '.term_color' "$CONFIG_FILE")"
if [[ -z "$TERM_COLOR" || "$TERM_COLOR" == "null" ]]; then
    TERM_COLOR="xterm-256color"
fi
OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT="$(jq -r '.oh_my_zsh_custom_theme_repo' "$CONFIG_FILE")"
if [[ -z "$OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT" || "$OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT" == "null" ]]; then
    OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT="romkatv/powerlevel10k"
fi
OH_MY_ZSH_CUSTOM_THEME_REPO=$OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT
OH_MY_ZSH_CUSTOM_THEME_REPO=$OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT
NVIM_LANGUAGES_DEFAULT=("$(jq -r '.nvim_languages[]' "$CONFIG_FILE")")
NVIM_LANGUAGES=("${NVIM_LANGUAGES_DEFAULT[@]}")

# Fonts
FONT_NAME="$(jq -r '.font_name' "$CONFIG_FILE")"
FONT_MESLOLGS_NF="MesloLGS NF"
if [[ -z "$FONT_NAME" || "$FONT_NAME" == "null" ]]; then
    FONT_NAME="$FONT_MESLOLGS_NF"
fi
FONT_URL="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20"

# Package managers
pkg_managers_keys=()
pkg_managers_values=()
parse_json_object 'pkg_managers' pkg_managers_keys pkg_managers_values

# Relative paths
while IFS= read -r line; do
    relative_paths+=("$line")
done < <(jq -r '.relative_paths[]' "$CONFIG_FILE")

# Plugins, common packages, distro-specific packages
plugins_values=()
plugins_keys=()
parse_json_object 'plugins' plugins_keys plugins_values

# Tmux plugins
tmux_plugins_keys=()
tmux_plugins_values=()
parse_json_object 'tmux_plugins' tmux_plugins_keys tmux_plugins_values

# Parse the common_packages array from the config.json file into a space-separated string
common_packages=$(jq -r '.common_packages[]' "$CONFIG_FILE" | tr '\n' ' ')

# Parse the distro_packages object from the config.json file
distro_packages_keys=()
distro_packages_values=()
parse_json_object 'distro_packages' distro_packages_keys distro_packages_values

# Load the fonts dictionary from the fonts.json file
font_names=()
font_urls=()
while IFS=":" read -r key value; do
    font_names+=("$key")
    font_urls+=("$value")
done < <(jq -r 'to_entries|map("\(.key):\(.value|tostring)")|.[]' "$DOTFILES_FONTS_CONFIG")


# ****************************
# ** Argument parsing logic **
# ****************************

# Check if the --it or --interactive argument was provided
if [[ $1 == "--it" || $1 == "--interactive" ]]; then

    # theme repository
    log_warn "Please enter the repository for the oh-my-zsh theme (default: ${OH_MY_ZSH_CUSTOM_THEME_REPO}):"
    read -r input
    OH_MY_ZSH_CUSTOM_THEME_REPO=${input:-$OH_MY_ZSH_CUSTOM_THEME_REPO}

    # font name
    font_playground_link=https://www.programmingfonts.org/
    log_warn "Please enter the number corresponding to the font you want to use (default: ${FONT_NAME}):\n
    (visit ${font_playground_link} to see the fonts in action)\n
    "

    # Print the font options
    printf '%s\n' "${font_names[@]}" | awk '{print NR, $0}' | column

    choice=""
    while true; do
        read -rp "Your choice: " choice
        if [[ -z $choice ]]; then
            log_warn "No selection made. Using default font: ${FONT_NAME}"
            break
        else
            if [[ ! $choice =~ ^[0-9]+$ ]] || ((choice < 1 || choice > ${#font_names[@]})); then
                log_warn "Invalid selection: $choice. Please select a number from the list."
            else
                FONT_NAME=${font_names[$((choice-1))]}
                FONT_URL=${font_urls[$((choice-1))]}
                break
            fi
        fi
    done

    # language
    log_warn "Please select the language scripts to install (separate multiple choices with spaces):"

    # Get the list of available language scripts
    language_scripts=("$(ls "${NVIM_LANGUAGE_SCRIPT_DIR}")")

    # Print the language script options
    printf '%s\n' "${language_scripts[@]}" | awk '{print NR, $0}' | column

    choice=""
    while true; do
        read -rp "Your choices: " choice
        if [[ -z $choice ]]; then
            log_warn "No selection made. Using default languages: ${NVIM_LANGUAGES[*]}"
            break
        else
            # Split the choice into an array of selected indices
            IFS=' ' read -ra selected_indices <<< "$choice"
            # Validate each selected index
            for index in "${selected_indices[@]}"; do
                if [[ ! $index =~ ^[0-9]+$ ]] || ((index < 1 || index > ${#language_scripts[@]})); then
                    log_warn "Invalid selection: $index. Please select numbers from the list."
                    continue 2
                fi
            done
            # If all selected indices are valid, break the loop
            break
        fi
    done

    # Get the selected language scripts
    for index in "${selected_indices[@]}"; do
        NVIM_LANGUAGES+=("${language_scripts[$((index-1))]}")
    done

    log_warn "Selected languages: ${NVIM_LANGUAGES[*]}"
else
    # Parse command-line options
    # -r: oh-my-zsh theme repository
    # -l: Neovim languages (comma-separated)
    # -f: font name
    while getopts "r:l:f:" opt; do
      case ${opt} in
        r)
            OH_MY_ZSH_CUSTOM_THEME_REPO="$OPTARG"
            ;;
        l)
            IFS=',' read -ra NVIM_LANGUAGES_USER <<< "$OPTARG"
            NVIM_LANGUAGES+=("${NVIM_LANGUAGES_USER[@]}")
            ;;
        f)
            FONT_NAME="$OPTARG"
            if [[ "$FONT_NAME" == "${FONT_MESLOLGS_NF}" ]] || printf '%s\n' "${font_names[@]}" | grep -q -F "$FONT_NAME"; then
                if [[ "$FONT_NAME" != "${FONT_MESLOLGS_NF}" ]]; then
                    FONT_INDEX=$(printf '%s\n' "${font_names[@]}" | grep -n -F "$FONT_NAME" | cut -d: -f1)
                    FONT_URL=${font_urls[$((FONT_INDEX-1))]}
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
fi

# ***********************
# ** Debug information **
# ***********************

if [[ "$CI" == "true" ]]; then
    log_info "
    Paths:
        ZSHRC: $ZSHRC
        NVIM_CONFIG_DIR: $NVIM_CONFIG_DIR
        NVIM_SCRIPTS_DIR: $NVIM_SCRIPTS_DIR
        NVIM_OPTIONS_FILE: $NVIM_OPTIONS_FILE
        CLIPBOARD_CONFIG_SCRIPT: $CLIPBOARD_CONFIG_SCRIPT
        NVIM_LANGUAGE_SCRIPT_DIR: $NVIM_LANGUAGE_SCRIPT_DIR

    Configuration file: $CONFIG_FILE
    Font file: $DOTFILES_FONTS_CONFIG

    Options:
        OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT: $OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT
        OH_MY_ZSH_CUSTOM_THEME_REPO: $OH_MY_ZSH_CUSTOM_THEME_REPO
        NVIM_LANGUAGES: ${NVIM_LANGUAGES[*]}
        FONT_NAME: $FONT_NAME
        FONT_URL: $FONT_URL

    Package managers:
        pkg_managers_keys: ${pkg_managers_keys[*]}
        pkg_managers_values: ${pkg_managers_values[*]}

    Relative paths: ${relative_paths[*]}

    Plugins:
        plugins_keys: ${plugins_keys[*]}
        plugins_values: ${plugins_values[*]}

    Tmux plugins:
        tmux_plugins_keys: ${tmux_plugins_keys[*]}
        tmux_plugins_values: ${tmux_plugins_values[*]}

    Terminal color: $TERM_COLOR

    Common packages: $common_packages

    Distro packages:
        distro_packages_keys: ${distro_packages_keys[*]}
        distro_packages_values: ${distro_packages_values[*]}
    "
fi

# ******************
# ** Source Zshrc **
# ******************

source_zshrc() {
    log_info "Sourcing .zshrc file"
    # Fix permissions before sourcing the .zshrc file
    zsh -c "export ZSH_DISABLE_COMPFIX=true; source $ZSHRC"
}



# *********************
# ** Get Index Value **
# *********************

get_index() {
    local value=$1
    for i in "${!pkg_managers_keys[@]}"; do
        if [[ "${pkg_managers_keys[$i]}" == "$value" ]]; then
            echo "$i"
            return
        fi
    done
}

# *******************
# ** Detect distro **
# *******************

detect_distro() {
    # Get the name of the current distribution
    local distro
    if [[ "$OSTYPE" == "darwin"* ]]; then
        distro="macos"
    else
        distro=$(awk -F= '/^NAME/{print tolower($2)}' /etc/os-release | tr -d '"' | awk '{print $1}')
    fi
    echo "$distro"
}

# **********************
# ** Install Packages **
# **********************

install_packages() {
    # Store the package manager passed as an argument
    local package_manager=$1

    log_info "Installing packages..."

    # Get the name of the current distribution
    echo "Detecting distribution..."
    local distro=""
    distro=$(detect_distro)
    echo "Detected distribution: $distro"

    # Start with the common packages
    local packages=("${common_packages[@]}")

    # Add the distro-specific packages to the list
    local distro_index
    distro_index=$(printf "%s\n" "${distro_packages_keys[@]}" | grep -n -x "$distro" | cut -d: -f1)
    local distro_specific_packages="${distro_packages_values[$((distro_index-1))]}"
    packages=("${packages[@]}" "$distro_specific_packages")

    # Get the update command for the package manager
    local pkg_manager_index
    pkg_manager_index=$(get_index "$package_manager")
    update_cmd="${pkg_managers_values[$pkg_manager_index]}"

    # Update the package lists
    log_info "Updating package lists for $package_manager with $update_cmd..."
    run_sudo_cmd "$update_cmd"

    # Install all packages in one command
    log_info "Installing packages with $package_manager..."
    case $package_manager in
        "apt-get")
            run_sudo_cmd "apt-get install -y ${packages[*]}"
            ;;
        "dnf")
            run_sudo_cmd "dnf install -y ${packages[*]}"
            ;;
        "yum")
            run_sudo_cmd "yum install -y ${packages[*]}"
            ;;
        "pacman")
            run_sudo_cmd "pacman -Syu --needed --noconfirm ${packages[*]}"
            ;;
        "brew")
            # Convert the space-separated string to an array for Homebrew
            IFS=' ' read -r -a brew_packages <<< "${packages[*]}"
            for package in "${brew_packages[@]}"; do
                if [[ "$CI" == "true" ]]; then
                    echo "CI environment detected. Installing $package without checking for installed dependents..."
                    HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1 brew install "$package"
                else
                    brew install "$package"
                fi
            done
            ;;
        *)
            log_error "Unsupported package manager: $package_manager"
            exit 1
            ;;
    esac

    log_success "Packages installed successfully!"
}


# *****************************
# ** Add variables to .zshrc **
# *****************************

append_env_variable_to_zshrc() {
    # If the variable is already set but commented out, it will be uncommented
    # If the variable is not set, it will be added to the end of the file

    # Name of the environment variable
    local var_name="$1"
    # Value of the environment variable
    local var_value="$2"

    # If the variable is already set but commented out, uncomment it
    if grep -q "^#.*export $var_name=$var_value" "$ZSHRC"; then
        log_info "Uncommenting $var_name environment variable"
        sed -i "s/^#.*export $var_name=$var_value/export $var_name=$var_value/" "$ZSHRC"
    # If the variable is not set, add it to the end of the file
    elif ! grep -q "$var_name=$var_value" "$ZSHRC"; then
        log_info "Setting $var_name environment variable"
        echo -e "\nexport $var_name=$var_value" >> "$ZSHRC"
    fi
}

# ********************
# ** Install Neovim **
# ********************

install_neovim() {
    # Define local variables
    local package_manager=$1
    log_info "Installing Neovim..."

    # Determine package manager and corresponding commands
    case "$package_manager" in
    "pacman")
        # Install Neovim via package manager
        run_sudo_cmd "pacman -Syu --noconfirm neovim"
        ;;
    "apt-get")
        # Check if Neovim is already installed
        if ! dpkg -s neovim &>/dev/null; then

            # Neovim variables
            nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
            nvim_tarball_name="nvim-linux64.tar.gz"
            nvim_install_dir="/opt/nvim-linux64"
            nvim_bin_dir="$nvim_install_dir/bin"

            # Create a temporary directory
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
            # Add the bin directory of the extracted archive to the PATH in .zshrc if it's not already there
            if ! grep -q "$nvim_bin_dir" "$ZSHRC"; then
                echo -e "\nexport PATH=\"\$PATH:$nvim_bin_dir\"" >> "$ZSHRC"
            fi
            # Also ensure that the bin directory is added to the PATH for the current session
            export PATH="$PATH:$nvim_bin_dir"

            # Install tree-sitter
            echo "Installing tree-sitter..."

            # Create a temporary directory
            ts_tmpdir=$(mktemp -d)
            # TS variables
            ts_binary_name="tree-sitter-linux-x64"
            ts_binary_url="https://github.com/tree-sitter/tree-sitter/releases/latest/download/$ts_binary_name.gz"
            # TS file paths
            ts_gz_file_path="$ts_tmpdir/$ts_binary_name.gz"
            ts_binary_file_path="$ts_tmpdir/$ts_binary_name"

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
    "yum")
        # Check if Neovim is already installed
        if ! yum list installed neovim &>/dev/null; then
            # Install Neovim via package manager
            run_sudo_cmd "yum install -y neovim"
        else
            log_info "Neovim is already installed"
        fi
        ;;
    "dnf")
        # Check if Neovim is already installed
        if ! dnf list installed neovim &>/dev/null; then
            # Install Neovim via package manager
            run_sudo_cmd "dnf install -y neovim"
        else
            # echo "Neovim is already installed"
            log_info "Neovim is already installed"
        fi
        ;;
    "brew")
        # Check if Neovim is already installed
        if ! brew list --versions neovim &>/dev/null; then
            # Install Neovim via package manager
            brew install neovim
        else
            log_info "Neovim is already installed"
        fi
        ;;
    *)
        log_warn "Unsupported package manager for Neovim installation. Building from source instead."
        # Clone Neovim repository
        git clone https://github.com/neovim/neovim.git
        cd neovim || exit
        # Build Neovim from source
        make CMAKE_BUILD_TYPE=Release
        run_sudo_cmd "make install"
        ;;
    esac

    log_success "Neovim installed successfully!"

    # Source zshrc
    source_zshrc
}

# **********************
# ** Configure Neovim **
# **********************

parse_neovim_config() {
    local key=$1
    local values
    # shellcheck disable=SC2207
    # shellcheck disable=SC2086
    # shellcheck disable=SC1087
    values=($(jq -r ".neovim.$key[]" $CONFIG_FILE))
    echo "${values[*]}"
}

configure_neovim() {
    # Define local variables
    local package_manager=$1

    log_info "Configuring Neovim..."

    # Ensure node and npm are installed, otherwise exit
    if ! command -v node &>/dev/null || ! command -v npm &>/dev/null; then
        log_error "Node.js and npm are required for Neovim configuration. Please install them and run this script again."
        exit 1
    fi

    # Parse variables from config.json
    parsers=$(parse_neovim_config "parsers")
    lsps=$(parse_neovim_config "lsps")
    daps=$(parse_neovim_config "daps")
    linters=$(parse_neovim_config "linters")
    formatters=$(parse_neovim_config "formatters")

    # nvim headless commands
    commands=('Lazy sync' "TSInstallSync! $parsers" 'MasonUpdate' "MasonInstall $lsps $daps $linters $formatters")
    if [ "$CI" = "true" ]; then
        # do nothing
        log_info "CI environment detected. Skipping headless commands."
    else
        # Run commands
        for cmd in "${commands[@]}"; do
            log_info "Running command: $cmd..."
            nvim --headless -c "$cmd" -c "quitall"
        done
    fi

    # Call the clipboard configuration script
    # shellcheck disable=SC1090
    source "$CLIPBOARD_CONFIG_SCRIPT" "$NVIM_OPTIONS_FILE"

    # CoPilot message
    log_warn "[Neovim CoPilot] Remember to install CoPilot with :CoPilot setup"

    # Call the relevant language-specific Neovim configure script for each selected language
    for language in "${NVIM_LANGUAGES[@]}"; do
        if [ -n "$language" ]; then
            language=${language%.sh} # Remove the .sh extension if it's present
            script="$NVIM_LANGUAGE_SCRIPT_DIR/${language}.sh"
            log_info "Checking for configuration script: $script"
            if [ -f "$script" ]; then
                echo "Configuring Neovim for $language..."
                # shellcheck disable=SC1090
                source "$script" "$package_manager"
            else
                log_error "No configuration script found for $language"
                exit 1
            fi
        fi
    done

    log_success "Neovim configured successfully!"
    
    # Source zshrc
    source_zshrc
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
}

# *******************
# ** Install fonts **
# *******************

install_fonts() {
    log_info "Installing ${FONT_NAME} fonts..."

    # Determine the OS and set the font directory accordingly
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
    if [[ "$FONT_NAME" = MesloLG* ]] && [[ "$OH_MY_ZSH_CUSTOM_THEME_REPO" = "$OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT" ]]; then
        # See https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#fonts
        # Download the font files
        font_files=()  # Clear the array
        for font_file in "Regular" "Bold" "Italic" "Bold Italic"; do
            # Replace spaces in font_file with %20 for the URL
            url_font_file=${font_file// /%20}
            log_info "Downloading MesloLGS NF ${font_file}.ttf..."
            wget -nv -P "$tmp_dir" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20${url_font_file}.ttf"
            # Add the full path to the downloaded file to the array
            font_files+=("$tmp_dir/MesloLGS NF $font_file.ttf")
        done
    else
        # Download the font file from the URL
        log_info "Downloading ${FONT_NAME} font..."
        wget -nv -P "$tmp_dir" "$FONT_URL"

        # Unzip the font file
        unzip "$tmp_dir"/*.zip -d "$tmp_dir"
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
    ZSH_INSTALLED=false
    OH_MY_ZSH_INSTALLED=false
    OH_MY_ZSH_DIR="$HOME"/.oh-my-zsh
    log_info "Checking if zsh is installed..."
    if [ -n "$(command -v zsh)" ]; then
        echo "zsh is installed"
        ZSH_INSTALLED=true

        # Check if oh-my-zsh.sh is present
        if [ ! -f "$OH_MY_ZSH_DIR"/oh-my-zsh.sh ]; then
            # Backup existing oh-my-zsh installation if it exists
            if [ -d "$OH_MY_ZSH_DIR" ]; then
                echo "Backing up existing oh-my-zsh installation..."
                mv "$OH_MY_ZSH_DIR" "$OH_MY_ZSH_DIR".bak
            fi

            # Install oh-my-zsh
            echo "Installing oh-my-zsh..."
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            OH_MY_ZSH_INSTALLED=true
        else
            echo "oh-my-zsh is already installed"
            OH_MY_ZSH_INSTALLED=true
        fi
    fi

    # If either zsh or oh-my-zsh are not installed, exit the script
    if [ "$ZSH_INSTALLED" = false ] || [ "$OH_MY_ZSH_INSTALLED" = false ]; then
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
        src="${DOTFILES_DIR}/${relative_path}"
        target="$HOME/$relative_path"
        create_symlink "$src" "$target"
    done
}

# *********************************
# ** Detect and install packages **
# *********************************

PKG_MANAGER=""
detect_and_install_packages() {
    # Check for package manager and install packages
    log_info "Detecting package manager..."
        for index in "${!pkg_managers_keys[@]}"; do
            pm="${pkg_managers_keys[$index]}"
            if command -v "$pm" >/dev/null 2>&1; then
                echo "Detected package manager: $pm"
                PKG_MANAGER=$pm
                install_packages "$PKG_MANAGER"
                break
            fi
        done

    # Check if a package manager was found
    if [ -z "$PKG_MANAGER" ]; then
        log_error "No package manager found"
        exit 1
    fi
}

# ***************************************
# ** Clone oh-my-zsh plugins and theme **
# ***************************************

clone_plugins_and_themes() {
    log_info "Cloning oh-my-zsh plugins and theme..."
    for index in "${!plugins_keys[@]}"; do
        plugin="${plugins_keys[$index]}"
        url="${plugins_values[$index]}"
        dir="$HOME/.oh-my-zsh/custom/plugins/$plugin"
        log_info "Checking $dir..."
        mkdir -p "$dir" # Ensure the directory exists
        if [ -d "$dir/.git" ]; then
            echo "Directory $dir already exists. Pulling latest changes..."
            git -C "$dir" pull
        else
            echo "Cloning $url into $dir..."
            git clone --depth=1 "$url" "$dir" # Clone the repository
        fi
    done
}

# ************************ 
# ** Clone tmux plugins **
# ************************

clone_tmux_plugins() {
    log_info "Cloning tmux plugins..."
    for index in "${!tmux_plugins_keys[@]}"; do
        plugin="${tmux_plugins_keys[$index]}"
        url="${tmux_plugins_values[$index]}"
        dir="$HOME/.tmux/plugins/$plugin"
        log_info "Checking $dir..."
        mkdir -p "$dir" # Ensure the directory exists
        if [ -d "$dir/.git" ]; then
            echo "Directory $dir already exists. Pulling latest changes..."
            git -C "$dir" pull
        else
            echo "Cloning $url into $dir..."
            git clone --depth=1 "$url" "$dir" # Clone the repository
        fi
    done
}

# **************************
# ** Install tmux plugins **
# **************************

install_tmux_plugins() {
    # Ensure tpm is installed
    TPM_DIR="$HOME/.tmux/plugins/tpm"
    if [ ! -d "$TPM_DIR" ]; then
        log_info "Tmux Plugin Manager not found. Cloning..."
        git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    fi

    # Install tmux plugins
    log_info "Installing tmux plugins..."
    SESSION_NAME="temp_$(date +%s)"
    if tmux new-session -d -s "$SESSION_NAME"; then
        if ! tmux source-file "$TMUX_CONF"; then
            log_error "Failed to source .tmux.conf"
        fi
        if ! "$TPM_DIR/bin/install_plugins"; then
            log_error "Failed to install tmux plugins"
        fi
        tmux kill-session -t "$SESSION_NAME"
    else
        log_error "Failed to create new tmux session"
    fi
    append_env_variable_to_zshrc "TERM" "$TERM_COLOR"
}

# **********************
# ** Configure Docker **
# **********************

configure_docker() {
    # Docker specific configuration
    if [ -f /.dockerenv ]; then
        log_info "Docker detected. Configuring environment for Docker..."
        # Set the language environment variables
        append_env_variable_to_zshrc "LANG" "C.UTF-8"
        append_env_variable_to_zshrc "LC_ALL" "en_US.UTF-8"
        
        # Generate locale
        log_info "Generating locale..."
        if type locale-gen &>/dev/null; then
            echo "Running locale-gen..."
            echo "en_US.UTF-8 UTF-8" | run_sudo_cmd "tee -a /etc/locale.gen"
            run_sudo_cmd "locale-gen"
        elif type localedef &>/dev/null; then
            echo "Running localedef..."
            run_sudo_cmd "echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen"
            run_sudo_cmd "localedef -i en_US -f UTF-8 en_US.UTF-8"
        elif [ "$(uname)" == "Darwin" ]; then
            echo "Running defaults write..."
            defaults write -g AppleLocale -string "en_US"
        else
            log_error "No supported method for generating locale found"
            exit 1
        fi
    fi
}

# *****************************
# ** Install oh-my-zsh theme **
# *****************************

install_oh_my_zsh_theme() {
    if command -v basename &> /dev/null
    then
        OH_MY_ZSH_THEME_NAME=$(basename "$OH_MY_ZSH_CUSTOM_THEME_REPO")
    else
        # Use parameter expansion as a fallback
        OH_MY_ZSH_THEME_NAME=${OH_MY_ZSH_CUSTOM_THEME_REPO##*/}
    fi

    if [ -z "$OH_MY_ZSH_THEME_NAME" ]; then
        log_error "Failed to extract theme name from $OH_MY_ZSH_CUSTOM_THEME_REPO"
        exit 1
    elif [ ! -d "$HOME/.oh-my-zsh/custom/themes/$OH_MY_ZSH_THEME_NAME" ]; then
        log_info "Installing $OH_MY_ZSH_THEME_NAME theme..."
        git clone --depth=1 https://github.com/"$OH_MY_ZSH_CUSTOM_THEME_REPO".git "$HOME"/.oh-my-zsh/custom/themes/"$OH_MY_ZSH_THEME_NAME"
    else
        log_info "$OH_MY_ZSH_THEME_NAME theme is already installed"
    fi
}

# **********
# ** Main **
# **********

main() {
    # Install zsh and oh-my-zsh
    install_zsh_and_oh_my_zsh

    # Create symlinks
    create_symlinks

    # Detect and install packages
    detect_and_install_packages

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

    # Source .zshrc file to apply the changes
    source_zshrc

    # Install Neovim
    install_neovim "$PKG_MANAGER"

    # Configure Neovim
    configure_neovim "$PKG_MANAGER"

    # Finish
    log_success "Dotfiles installation complete!"
}

# Run the main script
main
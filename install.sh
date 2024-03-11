#!/bin/bash

# Initialization
# shellcheck disable=SC1091
source "init.sh" 

log_info "Starting dotfiles installation..."

# Default values for the options
OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT="romkatv/powerlevel10k"
OH_MY_ZSH_CUSTOM_THEME_REPO=$OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT
NVIM_LANGUAGE="golang"
FONT_NAME="MesloLGS NF"
FONT_URL="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20"

# Load the fonts dictionary from the fonts.json file
declare -A fonts
while IFS=":" read -r key value; do
    fonts[$key]=$value
done < <(jq -r 'to_entries|map("\(.key):\(.value|tostring)")|.[]' fonts.json)

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
    font_keys=("${!fonts[@]}")
    printf '%s\n' "${font_keys[@]}" | awk '{print NR, $0}' | column

    choice=""
    while [[ ! $choice =~ ^[0-9]+$ ]] || ((choice < 1 || choice > ${#font_keys[@]})); do
        read -rp "Your choice: " choice
        if [[ -z $choice ]]; then
            log_warn "No selection made. Using default font: ${FONT_NAME}"
            FONT_URL=${fonts[$FONT_NAME]}
            break
        elif ((choice >= 1 && choice <= ${#font_keys[@]})); then
            FONT_NAME=${font_keys[$((choice-1))]}
            FONT_URL=${fonts[$FONT_NAME]}
            log_warn "Selected font: ${FONT_NAME}"
            break
        else
            log_warn "Invalid selection. Please select a number from the list."
        fi
    done

    # language
    log_warn "Please enter the language (default: ${NVIM_LANGUAGE}):"
    read -r input
    NVIM_LANGUAGE=${input:-$NVIM_LANGUAGE}
else
    # Parse command-line options
    # -r: oh-my-zsh theme repository
    # -l: Neovim language
    # -f: font name
    while getopts "r:l:f" opt; do
      case ${opt} in
        r)
            OH_MY_ZSH_CUSTOM_THEME_REPO="$OPTARG"
            ;;
        l)
            NVIM_LANGUAGE="$OPTARG"
            ;;
        f)
            FONT_NAME="$OPTARG"
            FONT_URL=${fonts[$FONT_NAME]}
            ;;
        \?)
            log_error "Invalid option: -$OPTARG"
            exit 1
            ;;
      esac
    done
fi

# Default path to the .zshrc file
ZSHRC="$HOME/.zshrc"

# Default path to nvim configuration directory
NVIM_CONFIG_DIR="$REPO_DIR/.config/nvim"

# Default path to the scripts directory in nvim
NVIM_SCRIPTS_DIR="${NVIM_CONFIG_DIR}/scripts"

# Path to the nvim options.lua file
NVIM_OPTIONS_FILE="${NVIM_CONFIG_DIR}/lua/core/options.lua"

# Path to the clipboard configuration script
CLIPBOARD_CONFIG_SCRIPT="${NVIM_SCRIPTS_DIR}/clipboard.sh"

# Path to the language-specific Neovim configure scripts directory
NVIM_LANGUAGE_SCRIPT_DIR="${NVIM_SCRIPTS_DIR}/lang"

# Declare an associative array for package managers and their update commands
# The key is the package manager name and the value is the update command
declare -A pkg_managers=(
    ["apt-get"]="apt-get update"
    ["dnf"]="dnf check-update"
    ["yum"]="yum check-update"
    ["pacman"]="pacman -Syu --noconfirm"
    ["brew"]="brew update"
)

# Array of file paths relative to the repository directory
# These are the files that will be symlinked to the home directory
declare -a relative_paths=(
    ".zshrc"
    ".config/nvim"
    ".tmux.conf"
)

# Associative array mapping the plugin names to their git repository URLs
# These plugins will be cloned into the oh-my-zsh custom plugins directory
declare -A plugins=(
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions.git"
    ["zsh-history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search.git"
)

# List of common packages to install across all distros
common_packages=("git" "tmux" "wget" "fontconfig")

# Distro specific packages
# An associative array where the key is the distro name and the value is a string of packages for that distro
# Modfiy this array to add or remove packages for a specific distro as needed
declare -A distro_packages
distro_packages=(
    ["arch"]="lua xclip tree-sitter tree-sitter-cli unzip ripgrep fd"
    ["debian"]="lua5.4 xclip unzip ripgrep fd-find python3-venv"
    ["fedora"]="lua fd-find"
    ["ubuntu"]="lua5.4 fd-find python3-venv"
    ["macos"]="lua fd"
)

# ******************
# ** Source Zshrc **
# ******************

source_zshrc() {
    # Source .zshrc file to apply the changes
    log_info "Sourcing .zshrc file"
    zsh -c "source $ZSHRC"
}

# **********************
# ** Run Sudo Command **
# **********************

run_sudo_cmd() {
    if [[ "$CI" == "true" ]]; then
        # Run the command as a regular user in the CI environment
        eval "$1"
    else
        sudo sh -c "$1"
    fi
}

# **********************
# ** Install Packages **
# **********************

install_packages() {
    # Store the package manager passed as an argument
    local package_manager=$1
    local shell=$2

    # Get the name of the current distribution
    local distro
    if [[ "$OSTYPE" == "darwin"* ]]; then
        distro="macos"
    else
        distro=$(awk -F= '/^NAME/{print tolower($2)}' /etc/os-release | tr -d '"' | awk '{print $1}')
    fi

    # Start with the common packages
    local packages=("${common_packages[@]}")

    # Add the distro-specific packages to the list
    if [[ "$shell" == *"zsh"* ]]; then
        IFS=' ' read -r -A distro_specific_packages <<< "${distro_packages[$distro]}"
    else
        IFS=' ' read -r -a distro_specific_packages <<< "${distro_packages[$distro]}"
    fi
    packages=("${packages[@]}" "${distro_specific_packages[@]}")

    # Get the update command for the package manager
    update_cmd="${pkg_managers[$package_manager]}"

    # Update the package lists
    log_info "Updating package lists for $package_manager"
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
            run_sudo_cmd "pacman -S --noconfirm ${packages[*]}"
            ;;
        "brew")
            brew install "${packages[@]}"
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

    # Determine package manager and corresponding commands
    case "$package_manager" in
    "pacman")
        # Check if Neovim is already installed
        if ! pacman -Q neovim &>/dev/null; then
            log_info "Installing Neovim..."
            # Install Neovim via package manager
            run_sudo_cmd "pacman -S --noconfirm neovim"
        else
            log_info "Neovim is already installed"
        fi
        ;;
    "apt-get")
        # Check if Neovim is already installed
        if ! dpkg -s neovim &>/dev/null; then
            log_info "Installing Neovim..."

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
            log_info "Installing tree-sitter..."

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
            log_info "Installing Neovim..."
            # Install Neovim via package manager
            run_sudo_cmd "yum install -y neovim"
        else
            log_info "Neovim is already installed"
        fi
        ;;
    "dnf")
        # Check if Neovim is already installed
        if ! dnf list installed neovim &>/dev/null; then
            log_info "Installing Neovim..."
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
            log_info "Installing Neovim..."
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

configure_neovim() {
    # Define local variables
    local package_manager=$1

    log_info "Configuring Neovim..."

    # tree-sitter
    parsers="markdown_inline"

    # mason
    # TODO configure to allow dynamic installation based on the specified language
    lsps="gopls lua-language-server pyright typescript-language-server"
    daps="go-debug-adapter"
    linters="eslint_d"
    formatters="black goimports-reviser golines gomodifytags gotests prettierd stylua"
    
    # nvim headless commands
    commands=('Lazy sync' "TSInstallSync! $parsers" 'MasonUpdate' "MasonInstall $lsps $daps $linters $formatters")
    for cmd in "${commands[@]}"; do
        log_info "Running command: $cmd..."
        # Skip if CI environment variable is true
        if [ "$CI" != "true" ]; then
            zsh -c "nvim --headless -c \"$cmd\" -c \"quitall\""
        fi
    done

    # Call the clipboard configuration script
    # If no -c flag is provided, the script will use the default path "./configure_nvim_clipboard.sh"
    # shellcheck disable=SC1090
    source "$CLIPBOARD_CONFIG_SCRIPT" "$NVIM_OPTIONS_FILE"

    # CoPilot message
    log_warn "[Neovim CoPilot] Remember to install CoPilot with :CoPilot setup"

    # Call the relevant language-specific Neovim configure script based on the flag that was passed
    if [ -n "$NVIM_LANGUAGE" ]; then
        # shellcheck disable=SC1090
        source "$NVIM_LANGUAGE_SCRIPT_DIR/${NVIM_LANGUAGE}.sh" "$package_manager"
    fi

    # Docker specific configuration
    if [ -f /.dockerenv ]; then
        log_info "Docker detected. Configuring Neovim for Docker..."
        # Set the language environment variables
        append_env_variable_to_zshrc "LANG" "C.UTF-8"
        append_env_variable_to_zshrc "LC_ALL" "en_US.UTF-8"
        
        # Generate locale
        log_info "Generating locale..."
        if type locale-gen &>/dev/null; then
            echo "en_US.UTF-8 UTF-8" | run_sudo_cmd "tee -a /etc/locale.gen"
            run_sudo_cmd "locale-gen"
        elif [ "$(uname)" == "Linux" ]; then
            run_sudo_cmd "echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen"
            run_sudo_cmd "localedef -i en_US -f UTF-8 en_US.UTF-8"
        elif [ "$(uname)" == "Darwin" ]; then
            defaults write -g AppleLocale -string "en_US"
        else
            log_error "No supported method for generating locale found"
            exit 1
        fi
    fi

    log_success "Neovim configured successfully!"
    
    # Source zshrc
    source_zshrc
}
    
# *********************
# ** Create symlinks **
# ********************* 

create_symlink() {
    local source=$1
    local target=$2
    source=$(realpath "$source")
    log_info "Creating symlink from $source to $target"
    mkdir -p "$(dirname "$target")" # Ensure the parent directory exists
    # If the target is a directory, remove it
    if [ -d "$target" ]; then
        rm -rf "$target"
    fi
    ln -sf "$source" "$target"
}

# *********************
# ** Clone git repos **
# *********************

clone_git_repo() {
    local dir=$1
    local repo=$2
    log_info "Cloning $repo into $dir"
    mkdir -p "$dir" # Ensure the directory exists
    if [ -d "$dir/.git" ]; then
        log_info "Directory $dir already exists. Pulling latest changes..."
        git -C "$dir" pull
    else
        git clone --depth=1 "$repo" "$dir" # Clone the repository
    fi
}

# *******************
# ** Install fonts **
# *******************

install_fonts() {
    log_info "Installing ${FONT_NAME} fonts..."

    # Create a temporary directory
    tmp_dir=$(mktemp -d)

    # Check if the font starts with MesloLG and OH_MY_ZSH_CUSTOM_THEME_REPO equals OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT
    if [[ "$FONT_NAME" = MesloLG* ]] && [[ "$OH_MY_ZSH_CUSTOM_THEME_REPO" = "$OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT" ]]; then
        # See https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#fonts
        # Font file names
        font_files=("Regular" "Bold" "Italic" "Bold%20Italic")

        # Download the font files
        for font_file in "${font_files[@]}"; do
            log_info "Downloading MesloLGS NF ${font_file}.ttf..."
            wget -P "$tmp_dir" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20${font_file}.ttf"
        done
    else
        # Download the font file from the URL
        log_info "Downloading ${FONT_NAME} font..."
        wget -P "$tmp_dir" "$FONT_URL"

        # Unzip the font file
        unzip "$tmp_dir"/*.zip -d "$tmp_dir"
        font_files=("$tmp_dir"/*.ttf)
    fi

    # Determine the OS and move the font files to the correct directory
    case "$(uname)" in
    *nix | *ux)
        # Create the ~/.fonts directory if it doesn't exist
        mkdir -p ~/.fonts

        # Move the font files to the correct directory
        for font_file in "${font_files[@]}"; do
            mv "$font_file" ~/.fonts/
        done

        # Update the font cache
        fc-cache -fv
        ;;
    Darwin)
        # Create the ~/Library/Fonts directory if it doesn't exist
        mkdir -p ~/Library/Fonts

        # Move the font files to the correct directory
        for font_file in "${font_files[@]}"; do
            mv "$font_file" ~/Library/Fonts/
        done
        ;;
    *)
        log_error "Unsupported OS for font installation"
        exit 1
        ;;
    esac

    # Remove the temporary directory
    rm -r "$tmp_dir"

    log_success "${FONT_NAME} fonts installed successfully!"
}

# ******************
# ** Main Section **
# ******************

# Check if zsh is installed
ZSH_INSTALLED=false
OH_MY_ZSH_INSTALLED=false
log_info "Checking if zsh is installed..."
if [ -n "$(command -v zsh)" ]; then
    log_info "check: zsh is installed"
    ZSH_INSTALLED=true

    # Install oh-my-zsh if it's not already installed
    if [ ! -d "$HOME"/.oh-my-zsh ]; then
        log_info "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        OH_MY_ZSH_INSTALLED=true
    else
        OH_MY_ZSH_INSTALLED=true
    fi
fi

# If either zsh or oh-my-zsh are not installed, exit the script
if [ "$ZSH_INSTALLED" = false ] || [ "$OH_MY_ZSH_INSTALLED" = false ]; then
    log_error "Either zsh or oh-my-zsh is not installed, cannot source .zshrc file"
    exit 1
fi

# Create symlinks for all files in the relative_paths array
for relative_path in "${relative_paths[@]}"; do
    src=$relative_path
    target="$HOME/$relative_path"
    create_symlink "$src" "$target"
done

# Get the current shell
log_info "Detecting current shell..."
CURRENT_SHELL=""
if [ -n "$BASH" ]; then
    CURRENT_SHELL="bash"
elif [ -n "$ZSH_NAME" ]; then
    CURRENT_SHELL="zsh"
else
    log_error "Unsupported shell for dotfiles installation ($CURRENT_SHELL)"
    exit 1
fi

# Check for package manager and install packages
PKG_MANAGER=""
msg_clone_plugins="Cloning oh-my-zsh plugins and theme..."
log_info "Detecting package manager for $CURRENT_SHELL..."
case $CURRENT_SHELL in
  zsh)
    # Zsh syntax
    # shellcheck disable=SC2296
    for pm in ${(k)pkg_managers}; do
        if command -v "$pm" >/dev/null 2>&1; then
            log_info "Detected package manager: $pm"
            PKG_MANAGER=$pm
            install_packages "$PKG_MANAGER" "$CURRENT_SHELL"
            break
        fi
    done

    # Clone plugins and theme
    log_info "$msg_clone_plugins"
    # shellcheck disable=SC2296
    for plugin in ${(k)plugins}; do
        clone_git_repo "$HOME/.oh-my-zsh/custom/plugins/$plugin" "${plugins[$plugin]}"
    done
    ;;
  bash)
    # Bash syntax
    for pm in "${!pkg_managers[@]}"; do
        if command -v "$pm" >/dev/null 2>&1; then
            log_info "Detected package manager: $pm"
            PKG_MANAGER=$pm
            install_packages "$PKG_MANAGER" "$CURRENT_SHELL"
            break
        fi
    done

    # Clone plugins and theme
    log_info "$msg_clone_plugins"
    for plugin in "${!plugins[@]}"; do
        clone_git_repo "$HOME/.oh-my-zsh/custom/plugins/$plugin" "${plugins[$plugin]}"
    done
    ;;
    *)
    log_error "Unsupported shell for package installation ($CURRENT_SHELL)"
    exit 1
    ;;
esac

# Check if a package manager was found
if [ -z "$PKG_MANAGER" ]; then
    log_error "No package manager found, skipping package installation"
    exit 1
fi

# Install oh-my-zsh theme
OH_MY_ZSH_THEME_INSTALLED=false
# Extract the theme name from the repository URL to use as custom theme name
OH_MY_ZSH_THEME_NAME=$(basename "$OH_MY_ZSH_CUSTOM_THEME_REPO")
if [ -z "$OH_MY_ZSH_THEME_NAME" ]; then
    log_error "Failed to extract theme name from $OH_MY_ZSH_CUSTOM_THEME_REPO"
    exit 1
fi
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/$OH_MY_ZSH_THEME_NAME" ]; then
    log_info "Installing $OH_MY_ZSH_THEME_NAME theme..."
    git clone --depth=1 https://github.com/"$OH_MY_ZSH_CUSTOM_THEME_REPO".git "$HOME"/.oh-my-zsh/custom/themes/"$OH_MY_ZSH_THEME_NAME"
    OH_MY_ZSH_THEME_INSTALLED=true
else
    OH_MY_ZSH_THEME_INSTALLED=true
fi

# Install fonts
install_fonts

# Source .zshrc file to apply the changes
if [ "$OH_MY_ZSH_THEME_INSTALLED" = true ]; then
    source_zshrc
else
    log_error "Cannot source .zshrc file because $OH_MY_ZSH_THEME_NAME theme was not found"
    exit 1
fi

# Install Neovim
install_neovim "$PKG_MANAGER"

# Configure Neovim
configure_neovim "$PKG_MANAGER"

# Finish
log_success "Dotfiles installation complete!"
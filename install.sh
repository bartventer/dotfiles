#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
INFO='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installing dotfiles...${NC}"

# Default to skipping prompts
INTERACTIVE=false

# Check if the --it or --interactive argument was provided
if [[ $1 == "--it" || $1 == "--interactive" ]]; then
    INTERACTIVE=true
fi

# Default values for the options
OH_MY_ZSH_THEME_NAME="powerlevel10k"
OH_MY_ZSH_THEME_REPO="romkatv/powerlevel10k"
NVIM_LANGUAGE="golang"

# If interactive mode is enabled, ask the user for the options
if [ "$INTERACTIVE" = true ] ; then
    echo -e "${YELLOW}Please enter the name of the theme you want to use for oh-my-zsh (default: ${OH_MY_ZSH_THEME_NAME}):${NC}"
    read -r input
    OH_MY_ZSH_THEME_NAME=${input:-$OH_MY_ZSH_THEME_NAME}

    echo -e "${YELLOW}Please enter the repository for the oh-my-zsh theme (default: ${OH_MY_ZSH_THEME_REPO}):${NC}"
    read -r input
    OH_MY_ZSH_THEME_REPO=${input:-$OH_MY_ZSH_THEME_REPO}

    echo -e "${YELLOW}Please enter the language (default: ${NVIM_LANGUAGE}):${NC}"
    read -r input
    NVIM_LANGUAGE=${input:-$NVIM_LANGUAGE}
fi

# Parse command-line options
# Use -t to specify a custom theme name for oh-my-zsh
# Use -r to specify a custom theme repository for oh-my-zsh
# Use -l to specify a language
# Example: ./install.sh -t custom-theme -r custom/repo -l rust
while getopts "t:r:l:" opt; do
  case ${opt} in
    t)
      OH_MY_ZSH_THEME_NAME="$OPTARG"
      ;;
    r)
      OH_MY_ZSH_THEME_REPO="$OPTARG"
      ;;
    l)
      NVIM_LANGUAGE="$OPTARG"
      ;;
    \?)
      echo -e "${RED}Invalid option: -$OPTARG${NC}" 1>&2
      exit 1
      ;;
  esac
done

# Define the repository directory for dotfiles
REPO_DIR="$HOME/dotfiles"

# If CI environment variable is true, override the REPO_DIR
if [ "$CI" = "true" ]; then
    REPO_DIR="$GITHUB_WORKSPACE"
fi

# Default path to the .zshrc file
ZSHRC="$HOME/.zshrc"

# Default theme name and repository for oh-my-zsh, defaults to powerlevel10k
OH_MY_ZSH_THEME_NAME="powerlevel10k"
OH_MY_ZSH_THEME_REPO="romkatv/powerlevel10k"

# Default path to the scripts directory in nvim
NVIM_SCRIPTS_DIR=".config/nvim/scripts"

# Default path to the configure_nvim_clipboard.sh script
CLIPBOARD_CONFIG_SCRIPT="${NVIM_SCRIPTS_DIR}/clipboard.sh"

# Default path to the language-specific Neovim configure script
NVIM_LANGUAGE_SCRIPT="${NVIM_SCRIPTS_DIR}/lang"

# Default language for Neovim configuration, defaults to golang
NVIM_LANGUAGE="golang"

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
    echo -e "${INFO}Sourcing .zshrc file${NC}"
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
    echo -e "${INFO}Updating package lists for $package_manager...${NC}"
    run_sudo_cmd "$update_cmd"

    # Install all packages in one command
    echo -e "${INFO}Installing packages with $package_manager...${NC}"
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
            echo -e "${RED}Unsupported package manager: $package_manager${NC}"
            exit 1
            ;;
    esac

    echo -e "${GREEN}Packages installed successfully!${NC}"
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
            echo -e "${INFO}Installing Neovim${NC}"
            # Install Neovim via package manager
            run_sudo_cmd "pacman -S --noconfirm neovim"
        else
            echo -e "${INFO}Neovim is already installed${NC}"
        fi
        ;;
    "apt-get")
        # Check if Neovim is already installed
        if ! dpkg -s neovim &>/dev/null; then
            echo -e "${INFO}Installing Neovim${NC}"

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
            echo -e "${INFO}Installing tree-sitter${NC}"

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
            echo -e "${INFO}Neovim is already installed${NC}"
        fi
        ;;
    "yum")
        # Check if Neovim is already installed
        if ! yum list installed neovim &>/dev/null; then
            echo -e "${INFO}Installing Neovim${NC}"
            # Install Neovim via package manager
            run_sudo_cmd "yum install -y neovim"
        else
            echo -e "${INFO}Neovim is already installed${NC}"
        fi
        ;;
    "dnf")
        # Check if Neovim is already installed
        if ! dnf list installed neovim &>/dev/null; then
            echo -e "${INFO}Installing Neovim${NC}"
            # Install Neovim via package manager
            run_sudo_cmd "dnf install -y neovim"
        else
            # echo "Neovim is already installed"
            echo -e "${INFO}Neovim is already installed${NC}"
        fi
        ;;
    "brew")
        # Check if Neovim is already installed
        if ! brew list --versions neovim &>/dev/null; then
            echo -e "${INFO}Installing Neovim${NC}"
            # Install Neovim via package manager
            brew install neovim
        else
            echo -e "${INFO}Neovim is already installed${NC}"
        fi
        ;;
    *)
        echo -e "${YELLOW}Unsupported package manager for Neovim installation. Building from source instead.${NC}"
        # Clone Neovim repository
        git clone https://github.com/neovim/neovim.git
        cd neovim || exit
        # Build Neovim from source
        make CMAKE_BUILD_TYPE=Release
        run_sudo_cmd "make install"
        ;;
    esac

    # echo -e "\e[32mNeovim installed successfully!\e[0m"
    echo -e "${GREEN}Neovim installed successfully!${NC}"

    # Source zshrc
    source_zshrc
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
        echo -e "${INFO}Uncommenting $var_name environment variable${NC}"
        sed -i "s/^#.*export $var_name=$var_value/export $var_name=$var_value/" "$ZSHRC"
    # If the variable is not set, add it to the end of the file
    elif ! grep -q "$var_name=$var_value" "$ZSHRC"; then
        echo -e "${INFO}Setting $var_name environment variable${NC}"
        echo -e "\nexport $var_name=$var_value" >> "$ZSHRC"
    fi
}

# **********************
# ** Configure Neovim **
# **********************

configure_neovim() {
    # Define local variables
    local package_manager=$1

    echo -e "${INFO}Configuring Neovim...${NC}"
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
        echo -e "${INFO}Running command: $cmd...${NC}"
        # Skip if CI environment variable is true
        if [ "$CI" != "true" ]; then
            zsh -c "nvim --headless -c \"$cmd\" -c \"quitall\""
        fi
    done

    # Call the clipboard configuration script
    # If no -c flag is provided, the script will use the default path "./configure_nvim_clipboard.sh"
    echo -e "${INFO}Configuring Neovim clipboard...${NC}"
    # shellcheck disable=SC1090
    zsh -c "source $REPO_DIR/$CLIPBOARD_CONFIG_SCRIPT $package_manager"

    # CoPilot message
    printf "\n%s[Neovim CoPilot]%s\nRemember to install CoPilot with :CoPilot setup\n" "${YELLOW}" "${NC}"


    # Call the relevant language-specific Neovim configure script based on the flag that was passed
    if [ -n "$NVIM_LANGUAGE" ]; then
        echo -e "${INFO}Configuring Neovim for $NVIM_LANGUAGE...${NC}"
        # shellcheck disable=SC1090
        zsh -c "source $REPO_DIR/$NVIM_LANGUAGE_SCRIPT/${NVIM_LANGUAGE}.sh $package_manager"
    fi

    # Docker specific configuration
    if [ -f /.dockerenv ]; then
        echo -e "${INFO}Docker detected. Configuring Neovim for Docker...${NC}"
        # Set the language environment variables
        append_env_variable_to_zshrc "LANG" "en_US.UTF-8"
        append_env_variable_to_zshrc "LC_ALL" "en_US.UTF-8"
    fi

    echo -e "${GREEN}Neovim configured successfully!${NC}"
    
    # Source zshrc
    source_zshrc
}
    
# *********************
# ** Create symlinks **
# ********************* 

create_symlink() {
    local source=$1
    local target=$2
    echo -e "${INFO}Creating symlink from $source to $target${NC}"
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
    echo -e "${INFO}Cloning $repo into $dir${NC}"
    mkdir -p "$dir" # Ensure the directory exists
    if [ -d "$dir/.git" ]; then
        echo -e "${INFO}Directory $dir already exists. Pulling latest changes.${NC}"
        git -C "$dir" pull
    else
        git clone --depth=1 "$repo" "$dir" # Clone the repository
    fi
}

# *********************************
# ** Install powerlevel10k fonts **
# *********************************

# See https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#fonts
install_powerlevel10k_fonts() {

    echo -e "${INFO}Installing Powerlevel10k fonts...${NC}"

    # Font file names
    font_files=("Regular" "Bold" "Italic" "Bold%20Italic")

    # Create a temporary directory
    tmp_dir=$(mktemp -d)

    # Download the font files
    for font_file in "${font_files[@]}"; do
        wget -P "$tmp_dir" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20${font_file}.ttf"
    done

    # Determine the OS and move the font files to the correct directory
    case "$(uname)" in
    *nix | *ux)
        # Create the ~/.fonts directory if it doesn't exist
        mkdir -p ~/.fonts

        # Move the font files to the correct directory
        mv "$tmp_dir"/MesloLGS*.ttf ~/.fonts/

        # Update the font cache
        fc-cache -fv
        ;;
    Darwin)
        # Create the ~/Library/Fonts directory if it doesn't exist
        mkdir -p ~/Library/Fonts

        # Move the font files to the correct directory
        mv "$tmp_dir"/MesloLGS*.ttf ~/Library/Fonts/
        ;;
    *)
        echo "Unsupported OS for font installation"
        ;;
    esac

    # Remove the temporary directory
    rm -r "$tmp_dir"

    echo -e "${GREEN}Powerlevel10k fonts installed successfully!${NC}"
}

# ******************
# ** Main Section **
# ******************

# Check if zsh is installed
ZSH_INSTALLED=false
OH_MY_ZSH_INSTALLED=false
if [ -n "$(command -v zsh)" ]; then
    echo -e "${INFO}zsh found${NC}"
    ZSH_INSTALLED=true

    # Install oh-my-zsh if it's not already installed
    if [ ! -d "$HOME"/.oh-my-zsh ]; then
        echo -e "${INFO}Installing oh-my-zsh...${NC}"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        OH_MY_ZSH_INSTALLED=true
    else
        OH_MY_ZSH_INSTALLED=true
    fi
fi

# If either zsh or oh-my-zsh are not installed, exit the script
if [ "$ZSH_INSTALLED" = false ] || [ "$OH_MY_ZSH_INSTALLED" = false ]; then
    echo -e "${RED}Either zsh or oh-my-zsh is not installed, cannot source .zshrc file${NC}"
    exit 1
fi

# Create symlinks for all files in the relative_paths array
for relative_path in "${relative_paths[@]}"; do
    source="$REPO_DIR/$relative_path"
    target="$HOME/$relative_path"
    create_symlink "$source" "$target"
done

# Get the current shell
CURRENT_SHELL=""
if [ -n "$BASH" ]; then
    CURRENT_SHELL="bash"
elif [ -n "$ZSH_NAME" ]; then
    CURRENT_SHELL="zsh"
else
    echo -e "${RED}Unsupported shell for dotfiles installation ($CURRENT_SHELL)${NC}"
    exit 1
fi

# Check for package manager and install packages
PKG_MANAGER=""
msg_clone_plugins="Cloning oh-my-zsh plugins and theme..."
case $CURRENT_SHELL in
  zsh)
    # Zsh syntax
    # shellcheck disable=SC2296
    for pm in ${(k)pkg_managers}; do
        if command -v "$pm" >/dev/null 2>&1; then
            echo -e "${INFO}$pm found${NC}"
            PKG_MANAGER=$pm
            install_packages "$PKG_MANAGER" "$CURRENT_SHELL"
            break
        fi
    done

    # Clone plugins and theme
    echo -e "${INFO}$msg_clone_plugins${NC}"
    # shellcheck disable=SC2296
    for plugin in ${(k)plugins}; do
        clone_git_repo "$HOME/.oh-my-zsh/custom/plugins/$plugin" "${plugins[$plugin]}"
    done
    ;;
  bash)
    # Bash syntax
    for pm in "${!pkg_managers[@]}"; do
        if command -v "$pm" >/dev/null 2>&1; then
            echo -e "${INFO}$pm found${NC}"
            PKG_MANAGER=$pm
            install_packages "$PKG_MANAGER" "$CURRENT_SHELL"
            break
        fi
    done

    # Clone plugins and theme
    echo -e "${INFO}$msg_clone_plugins${NC}"
    for plugin in "${!plugins[@]}"; do
        clone_git_repo "$HOME/.oh-my-zsh/custom/plugins/$plugin" "${plugins[$plugin]}"
    done
    ;;
    *)
    echo -e "${RED}Unsupported shell for package installation ($CURRENT_SHELL)${NC}"
    exit 1
    ;;
esac

# Check if a package manager was found
if [ -z "$PKG_MANAGER" ]; then
    echo -e "${RED}No package manager found, skipping package installation${NC}"
    exit 1
fi

# Install oh-my-zsh theme
OH_MY_ZSH_THEME_INSTALLED=false
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/$OH_MY_ZSH_THEME_NAME" ]; then
    echo -e "${INFO}Installing $OH_MY_ZSH_THEME_NAME theme...${NC}"
    git clone --depth=1 https://github.com/"$OH_MY_ZSH_THEME_REPO".git "$HOME"/.oh-my-zsh/custom/themes/"$OH_MY_ZSH_THEME_NAME"
    OH_MY_ZSH_THEME_INSTALLED=true
else
    OH_MY_ZSH_THEME_INSTALLED=true
fi

# Install powerlevel10k fonts
install_powerlevel10k_fonts

# Source .zshrc file to apply the changes
if [ "$OH_MY_ZSH_THEME_INSTALLED" = true ]; then
    source_zshrc
else
    echo -e "${RED}Cannot source .zshrc file because $OH_MY_ZSH_THEME_NAME theme was not found${NC}"
    exit 1
fi

# Install Neovim
install_neovim "$PKG_MANAGER"

# Configure Neovim
configure_neovim "$PKG_MANAGER"

# Finish
echo -e "${GREEN}Dotfiles installation complete!${NC}"
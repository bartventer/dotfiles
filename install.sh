#!/bin/bash

# List of common packages to install
common_packages=("git" "tmux" "wget" "fontconfig")

# Distro specific packages
declare -A distro_packages
distro_packages=(
    ["arch"]="lua xclip tree-sitter ripgrep fd"
    ["debian"]="lua5.4 xclip ripgrep fd-find python3-venv"
    ["fedora"]="lua fd-find"
    ["ubuntu"]="lua5.4 fd-find python3-venv"
)

# Define the repository directory for dotfiles
REPO_DIR="$HOME/dotfiles"

# Array of file paths relative to the repository directory
declare -a relative_paths=(
    ".zshrc"
    ".config/nvim"
    ".tmux.conf"
)
# Associative array mapping the plugin names to their git repository URLs
declare -A plugins=(
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions.git"
    ["zsh-history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search.git"
)

# Default theme name and repository for oh-my-zsh, defaults to powerlevel10k
OH_MY_ZSH_THEME_NAME="powerlevel10k"
OH_MY_ZSH_THEME_REPO="romkatv/powerlevel10k"

# Default path to the scripts directory in nvim
NVIM_SCRIPTS_DIR=".config/nvim/scripts"

# Default path to the configure_nvim_clipboard.sh script
CLIPBOARD_CONFIG_SCRIPT="${NVIM_SCRIPTS_DIR}/clipboard.sh"

# Default language for Neovim configuration, defaults to golang
NVIM_LANGUAGE="golang"

# Parse command-line options
# Use -t or --theme to specify a custom theme name for oh-my-zsh
# Use -r or --repo to specify a custom theme repository for oh-my-zsh
# Use -c or --clipboard-config to specify a custom path to the configure_nvim_clipboard.sh script
# Use -l or --language to specify a language
# Example: ./install.sh --theme custom-theme --repo custom/repo --clipboard-config /path/to/configure_nvim_clipboard.sh --language python
OPTIONS=t:r:c:l:
LONGOPTS=theme:,repo:,clipboard-config:,language:
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
eval set -- "$PARSED"

while true; do
  case "$1" in
    -t|--theme)
      OH_MY_ZSH_THEME_NAME="$2"
      shift 2
      ;;
    -r|--repo)
      OH_MY_ZSH_THEME_REPO="$2"
      shift 2
      ;;
    -c|--clipboard-config)
      CLIPBOARD_CONFIG_SCRIPT="$2"
      shift 2
      ;;
    -l|--language)
      NVIM_LANGUAGE="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Invalid option: -$1" 1>&2
      exit 1
      ;;
  esac
done

# Function to install packages
install_packages() {
    # The package manager command to check if a package is installed
    local package_manager=$1
    # The command to install a package
    local install_command=$2
    # Get the name of the current distribution
    local distro
    distro=$(awk -F= '/^NAME/{print tolower($2)}' /etc/os-release | tr -d '"' | awk '{print $1}')
    # Start with the common packages
    local packages=("${common_packages[@]}")
    # Add the distribution-specific packages to the list
    IFS=' ' read -r -a distro_specific_packages <<< "${distro_packages[$distro]}"
    packages+=("${distro_specific_packages[@]}")
    # Loop through the list of packages
    for package in "${packages[@]}"; do
        # If the package is not installed
        if ! $package_manager "$package" &>/dev/null; then
            echo "Installing $package"
            # Install the package
            # shellcheck disable=SC2086
            sudo $install_command -y "$package"
        else
            # If the package is already installed, print a message
            echo "$package is already installed"
        fi
    done
}

# Function to install Neovim
install_neovim() {
    # Define local variables
    local package_manager=$1

    # Determine package manager and corresponding commands
    case "$package_manager" in
    "pacman -Q")
        # Check if Neovim is already installed
        if ! pacman -Q neovim &>/dev/null; then
            echo "Installing Neovim"
            # Install Neovim via package manager
            sudo pacman -S --noconfirm neovim
        else
            echo "Neovim is already installed"
        fi
        ;;
    "apt-get")
        # Check if Neovim is already installed
        if ! dpkg -s neovim &>/dev/null; then
            echo "Installing Neovim"
            # Create a temporary directory
            tmpdir=$(mktemp -d)
            # Download the pre-built binary for Neovim into the temporary directory
            curl -L https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz -o "$tmpdir/nvim-linux64.tar.gz"
            # Extract the downloaded archive in the temporary directory
            tar -C "$tmpdir" -xzf "$tmpdir/nvim-linux64.tar.gz"
            # Move the extracted directory to /opt
            sudo mv "$tmpdir/nvim-linux64" /opt/
            # Remove the temporary directory
            rm -r "$tmpdir"
            # Add the bin directory of the extracted archive to the PATH
            echo "export PATH=\"\$PATH:/opt/nvim-linux64/bin\"" >> ~/.zshrc

            # Install tree-sitter
            echo "Installing tree-sitter"
            # Create a temporary directory
            tmpdir=$(mktemp -d)
            # Download the precompiled binary for tree-sitter
            curl -L https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz -o "$tmpdir/tree-sitter-linux-x64.gz"
            # Extract the downloaded archive to the temporary directory
            gunzip "$tmpdir/tree-sitter-linux-x64.gz"
            # Make the binary executable
            chmod +x "$tmpdir/tree-sitter-linux-x64"
            # Move the binary to /usr/local/bin
            sudo mv "$tmpdir/tree-sitter-linux-x64" /usr/local/bin/tree-sitter
            # Remove the temporary directory
            rm -r "$tmpdir"

        else
            echo "Neovim is already installed"
        fi
        ;;
    "yum")
        # Check if Neovim is already installed
        if ! yum list installed neovim &>/dev/null; then
            echo "Installing Neovim"
            # Install Neovim via package manager
            sudo yum install -y neovim
        else
            echo "Neovim is already installed"
        fi
        ;;
    "dnf")
        # Check if Neovim is already installed
        if ! dnf list installed neovim &>/dev/null; then
            echo "Installing Neovim"
            # Install Neovim via package manager
            sudo dnf install -y neovim
        else
            echo "Neovim is already installed"
        fi
        ;;
    *)
        echo "Unsupported package manager for Neovim installation. Building from source instead."
        # Clone Neovim repository
        git clone https://github.com/neovim/neovim.git
        cd neovim || exit
        # Build Neovim from source
        make CMAKE_BUILD_TYPE=Release
        sudo make install
        ;;
    esac

   # Install Neovim plugins, extra TS parsers, run Mason update, and install null-ls executables
    echo "Installing Neovim plugins, extra tree-sitter parsers, running Mason update, and installing null-ls executables"
    treesitter_parsers="markdown_inline"
    null_ls_executables="stylua eslint_d prettierd black goimports_reviser"
    nvim --headless \
        -c 'Lazy sync' \
        -c "TSInstallSync $treesitter_parsers" \
        -c 'MasonUpdate' \
        -c "MasonInstall $null_ls_executables" \
        -c 'quit'

    # Call the clipboard configuration script
    # If no -c flag is provided, the script will use the default path "./configure_nvim_clipboard.sh"
    echo "Configuring Neovim clipboard"
    # shellcheck disable=SC1090
    source "$CLIPBOARD_CONFIG_SCRIPT"

    printf "\n
    \033[1;33m
    [Neovim CoPilot]
    Remember to install CoPilot with :CoPilot setup
    \033[0m
    \n"

    # Call the relevant language-specific Neovim configure script based on the flag that was passed
    if [ -n "$NVIM_LANGUAGE" ]; then
        echo "Configuring Neovim for $NVIM_LANGUAGE"
        bash ".config/nvim/scripts/lang/${NVIM_LANGUAGE}.sh"
    fi
}

# Function to create symlinks from the source to the target
create_symlink() {
    local source=$1
    local target=$2
    echo "Creating symlink from $source to $target"
    mkdir -p "$(dirname "$target")" # Ensure the parent directory exists
    ln -sf "$source" "$target"
}

# Function to clone git repositories into the specified directory
clone_git_repo() {
    local dir=$1
    local repo=$2
    echo "Cloning $repo into $dir"
    mkdir -p "$dir" # Ensure the directory exists
    if [ -d "$dir/.git" ]; then
        echo "Directory $dir already exists. Pulling latest changes."
        git -C "$dir" pull
    else
        git clone --depth=1 "$repo" "$dir" # Clone the repository
    fi
}

# Function to install powerlevel10k fonts
# See https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#fonts
install_powerlevel10k_fonts() {
    # Font file names
    font_files=("Regular" "Bold" "Italic" "Bold%20Italic")

    # Download the font files
    for font_file in "${font_files[@]}"; do
        wget "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20${font_file}.ttf"
    done

    # Determine the OS and move the font files to the correct directory
    case "$(uname)" in
    *nix | *ux)
        # Create the ~/.fonts directory if it doesn't exist
        mkdir -p ~/.fonts

        # Move the font files to the correct directory
        mv MesloLGS*.ttf ~/.fonts/

        # Update the font cache
        fc-cache -fv
        ;;
    Darwin)
        # Create the ~/Library/Fonts directory if it doesn't exist
        mkdir -p ~/Library/Fonts

        # Move the font files to the correct directory
        mv MesloLGS*.ttf ~/Library/Fonts/
        ;;
    *)
        echo "Unsupported OS for font installation"
        ;;
    esac
}

# Create symlinks for all files in the relative_paths array
for relative_path in "${relative_paths[@]}"; do
    source="$REPO_DIR/$relative_path"
    target="$HOME/$relative_path"
    create_symlink "$source" "$target"
done

# Check for package manager, install packages, and source .zshrc file
case "$(uname)" in
*nix | *ux | Darwin*)
    if command -v apt-get >/dev/null 2>&1; then
        echo "apt-get found"
        sudo apt-get update # Update package lists
        install_packages "dpkg -s" "apt-get install -y"
        install_neovim "apt-get"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf found"
        sudo dnf check-update # Update package lists
        install_packages "dnf list installed" "dnf install -y"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum found"
        sudo yum check-update # Update package lists
        install_packages "rpm -q" "yum install -y"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman found"
        sudo pacman -Syu --noconfirm # Update package lists
        install_packages "pacman -Q" "pacman -S --noconfirm"
        install_neovim "pacman -Q"
    else
        if [ "$(uname)" = "Darwin" ]; then
            if command -v brew >/dev/null 2>&1; then
                echo "Homebrew found"
                brew update # Update package lists
                install_packages "brew list --versions" "brew install"
                install_neovim "brew list --versions"
            else
                echo "Homebrew not found. Please install it first."
                exit 1
            fi
        else
            echo "No known package manager found"
            exit 1
        fi
    fi

    if [ -n "$(command -v zsh)" ]; then
        echo "zsh is installed"

        # Install oh-my-zsh if it's not already installed
        if [ ! -d "$HOME"/.oh-my-zsh ]; then
            echo "Installing oh-my-zsh"
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        fi

        # Clone plugins and theme
        for plugin in "${!plugins[@]}"; do
            clone_git_repo "$HOME/.oh-my-zsh/custom/plugins/$plugin" "${plugins[$plugin]}"
        done

        # Check if the theme is already installed
        if [ ! -d "$HOME/.oh-my-zsh/custom/themes/$OH_MY_ZSH_THEME_NAME" ]; then
            echo "Installing $OH_MY_ZSH_THEME_NAME"
            git clone --depth=1 https://github.com/"$OH_MY_ZSH_THEME_REPO".git "$HOME"/.oh-my-zsh/custom/themes/"$OH_MY_ZSH_THEME_NAME"
        fi

        # Source .zshrc file to apply the changes
        echo "Sourcing .zshrc file"
        if [ -d "$HOME/.oh-my-zsh/custom/themes/$OH_MY_ZSH_THEME_NAME" ]; then
            zsh -c "source $HOME/.zshrc"
        else
            echo "Cannot source .zshrc file because $OH_MY_ZSH_THEME_NAME theme was not found"
        fi
    else
        echo "zsh not found, cannot source .zshrc file"
    fi
    ;;
*)
    echo "Unsupported OS"
    exit 1
    ;;
esac

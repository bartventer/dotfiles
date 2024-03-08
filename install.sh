#!/bin/bash

echo "Installing dotfiles..."
echo "Current printenv: $(printenv)"

# List of common packages to install across all distros
common_packages=("git" "tmux" "wget" "fontconfig")

# Distro specific packages
# An associative array where the key is the distro name and the value is a string of packages for that distro
declare -A distro_packages
distro_packages=(
    ["arch"]="lua xclip tree-sitter ripgrep fd"
    ["debian"]="lua5.4 xclip ripgrep fd-find python3-venv"
    ["fedora"]="lua fd-find"
    ["ubuntu"]="lua5.4 fd-find python3-venv"
    ["macos"]="lua fd"
)

# Declare an associative array for package managers and their update commands
# The key is the package manager name and the value is the update command
declare -A pkg_managers=(
    ["apt-get"]="apt-get update"
    ["dnf"]="dnf check-update"
    ["yum"]="yum check-update"
    ["pacman"]="pacman -Syu --noconfirm"
    ["brew"]="brew update"
)

# Define the repository directory for dotfiles
REPO_DIR="$HOME/dotfiles"

# If CI environment variable is true, override the REPO_DIR
if [ "$CI" = "true" ]; then
    REPO_DIR="$GITHUB_WORKSPACE"
fi


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

# Default path to the .zshrc file
ZSHRC="$HOME/.zshrc"

# Default theme name and repository for oh-my-zsh, defaults to powerlevel10k
OH_MY_ZSH_THEME_NAME="powerlevel10k"
OH_MY_ZSH_THEME_REPO="romkatv/powerlevel10k"

# Default path to the scripts directory in nvim
NVIM_SCRIPTS_DIR=".config/nvim/scripts"

# If CI environment variable is true, override the NVIM_SCRIPTS_DIR
if [ "$CI" = "true" ]; then
    NVIM_SCRIPTS_DIR="$GITHUB_WORKSPACE/.config/nvim/scripts"
fi

# Default path to the configure_nvim_clipboard.sh script
CLIPBOARD_CONFIG_SCRIPT="${NVIM_SCRIPTS_DIR}/clipboard.sh"

# Default path to the language-specific Neovim configure script
NVIM_LANGUAGE_SCRIPT="${NVIM_SCRIPTS_DIR}/lang"

# Default language for Neovim configuration, defaults to golang
NVIM_LANGUAGE="golang"

# Parse command-line options
# Use -t to specify a custom theme name for oh-my-zsh
# Use -r to specify a custom theme repository for oh-my-zsh
# Use -c to specify a custom path to the configure_nvim_clipboard.sh script
# Use -l to specify a language
# Example: ./install.sh -t custom-theme -r custom/repo -c /path/to/configure_nvim_clipboard.sh -l python
while getopts "t:r:c:l:" opt; do
  case ${opt} in
    t)
      OH_MY_ZSH_THEME_NAME="$OPTARG"
      ;;
    r)
      OH_MY_ZSH_THEME_REPO="$OPTARG"
      ;;
    c)
      CLIPBOARD_CONFIG_SCRIPT="$OPTARG"
      ;;
    l)
      NVIM_LANGUAGE="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" 1>&2
      exit 1
      ;;
  esac
done

# Function to source .zshrc
source_zshrc() {
    # Source .zshrc file to apply the changes
    echo "Sourcing .zshrc file"
    zsh -c "source $ZSHRC"
}

# Function to install packages
install_packages() {
    # Store the package manager passed as an argument
    local package_manager=$1

    # Get the name of the current distribution
    local distro
    if [[ "$OSTYPE" == "darwin"* ]]; then
        distro="macos"
    else
        distro=$(awk -F= '/^NAME/{print tolower($2)}' /etc/os-release | tr -d '"' | awk '{print $1}')
    fi

    # Start with the common packages
    local packages=("${common_packages[@]}")

    # Add the distribution-specific packages to the list
    distro_specific_packages=("${distro_packages[$distro]}")
    packages=("${packages[@]}" "${distro_specific_packages[@]}")

    # Get the update command for the package manager
    update_cmd="${pkg_managers[$package_manager]}"

    # Update the package lists
    echo "Updating package lists"
    if [[ "$CI" == "true" ]]; then
        eval "$update_cmd"
    else
        sudo sh -c "$update_cmd"
    fi

    # Loop through the list of packages
    for package in "${packages[@]}"; do
        # If the package is not installed
        case $package_manager in
            "apt-get")
                if ! dpkg -s "$package" >/dev/null 2>&1; then
                    echo "Installing $package"
                    if [[ "$CI" == "true" ]]; then
                        apt-get install -y "$package"
                    else
                        sudo apt-get install -y "$package"
                    fi
                else
                    echo "$package is already installed"
                fi
                ;;
            "dnf")
                if ! rpm -q "$package" >/dev/null 2>&1; then
                    echo "Installing $package"
                    if [[ "$CI" == "true" ]]; then
                        dnf install -y "$package"
                    else
                        sudo dnf install -y "$package"
                    fi
                else
                    echo "$package is already installed"
                fi
                ;;
            "yum")
                if ! rpm -q "$package" >/dev/null 2>&1; then
                    echo "Installing $package"
                    if [[ "$CI" == "true" ]]; then
                        yum install -y "$package"
                    else
                        sudo yum install -y "$package"
                    fi
                else
                    echo "$package is already installed"
                fi
                ;;
            "pacman")
                if ! pacman -Q "$package" >/dev/null 2>&1; then
                    echo "Installing $package"
                    if [[ "$CI" == "true" ]]; then
                        pacman -S --noconfirm "$package"
                    else
                        sudo pacman -S --noconfirm "$package"
                    fi
                else
                    echo "$package is already installed"
                fi
                ;;
            "brew")
                if ! brew list --versions "$package" >/dev/null 2>&1; then
                    echo "Installing $package"
                    brew install "$package"
                else
                    echo "$package is already installed"
                fi
                ;;
            *)
                echo "Unsupported package manager: $package_manager"
                ;;
        esac
    done
}

# Function to install Neovim
install_neovim() {
    # Define local variables
    local package_manager=$1

    # Determine package manager and corresponding commands
    case "$package_manager" in
    "pacman")
        # Check if Neovim is already installed
        if ! pacman -Q neovim &>/dev/null; then
            echo "Installing Neovim"
            # Install Neovim via package manager
            if [[ "$CI" == "true" ]]; then
                pacman -S --noconfirm neovim
            else
                sudo pacman -S --noconfirm neovim
            fi
        else
            echo "Neovim is already installed"
        fi
        ;;
    "apt-get")
        # Check if Neovim is already installed
        if ! dpkg -s neovim &>/dev/null; then
            echo "Installing Neovim"

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
            if [[ "$CI" == "true" ]]; then
                mv "$nvim_tmpdir/nvim-linux64" $nvim_install_dir
            else
                sudo mv "$nvim_tmpdir/nvim-linux64" $nvim_install_dir
            fi
            # Remove the temporary directory
            rm -r "$nvim_tmpdir"
            # Add the bin directory of the extracted archive to the PATH in .zshrc if it's not already there
            if ! grep -q "$nvim_bin_dir" "$ZSHRC"; then
                echo -e "\nexport PATH=\"\$PATH:$nvim_bin_dir\"" >> "$ZSHRC"
            fi
            # Also ensure that the bin directory is added to the PATH for the current session
            export PATH="$PATH:$nvim_bin_dir"

            # Install tree-sitter
            echo "Installing tree-sitter"

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
            if [[ "$CI" == "true" ]]; then
                mv "$ts_binary_file_path" /usr/local/bin/tree-sitter
            else
                sudo mv "$ts_binary_file_path" /usr/local/bin/tree-sitter
            fi
            # Remove the temporary directory
            rm -r "$ts_tmpdir"

        else
            echo "Neovim is already installed"
        fi
        ;;
    "yum")
        # Check if Neovim is already installed
        if ! yum list installed neovim &>/dev/null; then
            echo "Installing Neovim"
            # Install Neovim via package manager
            if [[ "$CI" == "true" ]]; then
                yum install -y neovim
            else
                sudo yum install -y neovim
            fi
        else
            echo "Neovim is already installed"
        fi
        ;;
    "dnf")
        # Check if Neovim is already installed
        if ! dnf list installed neovim &>/dev/null; then
            echo "Installing Neovim"
            # Install Neovim via package manager
            if [[ "$CI" == "true" ]]; then
                dnf install -y neovim
            else
                sudo dnf install -y neovim
            fi
        else
            echo "Neovim is already installed"
        fi
        ;;
    "brew")
        # Check if Neovim is already installed
        if ! brew list --versions neovim &>/dev/null; then
            echo "Installing Neovim"
            # Install Neovim via package manager
            brew install neovim
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
        if [[ "$CI" == "true" ]]; then
            make install
        else
            sudo make install
        fi
        ;;
    esac

    # Source zshrc
    source_zshrc

}

# Function to append an environment variable to .zshrc
# If the variable is already set but commented out, it will be uncommented
# If the variable is not set, it will be added to the end of the file
append_env_variable_to_zshrc() {
    # Name of the environment variable
    local var_name="$1"
    # Value of the environment variable
    local var_value="$2"

    # If the variable is already set but commented out, uncomment it
    if grep -q "^#.*export $var_name=$var_value" "$ZSHRC"; then
        echo "Uncommenting $var_name environment variable"
        sed -i "s/^#.*export $var_name=$var_value/export $var_name=$var_value/" "$ZSHRC"
    # If the variable is not set, add it to the end of the file
    elif ! grep -q "$var_name=$var_value" "$ZSHRC"; then
        echo "Setting $var_name environment variable"
        echo -e "\nexport $var_name=$var_value" >> "$ZSHRC"
    fi
}

# Function to configure Neovim
configure_neovim() {
    # Define local variables
    local package_manager=$1

    echo "Configuring Neovim..."
    treesitter_parsers="markdown_inline"
    null_ls_executables="stylua eslint_d prettierd black goimports-reviser"
    commands=('Lazy sync' "TSInstallSync $treesitter_parsers" 'MasonUpdate' "MasonInstall $null_ls_executables")
    for cmd in "${commands[@]}"; do
        echo "Running command: $cmd..."
        # Skip if CI environment variable is true
        if [ "$CI" != "true" ]; then
            zsh -c "nvim --headless -c \"$cmd\" -c \"quitall\""
        fi
    done

    # Call the clipboard configuration script
    # If no -c flag is provided, the script will use the default path "./configure_nvim_clipboard.sh"
    echo "Configuring Neovim clipboard"
    # shellcheck disable=SC1090
    zsh -c "source $REPO_DIR/$CLIPBOARD_CONFIG_SCRIPT $package_manager"

    # CoPilot message
    printf "\n
    \033[1;33m
    [Neovim CoPilot]
    Remember to install CoPilot with :CoPilot setup
    \033[0m
    \n"


    # Call the relevant language-specific Neovim configure script based on the flag that was passed
    if [ -n "$NVIM_LANGUAGE" ]; then
        echo "Configuring Neovim for $NVIM_LANGUAGE"
        # shellcheck disable=SC1090
        zsh -c "source $REPO_DIR/$NVIM_LANGUAGE_SCRIPT/${NVIM_LANGUAGE}.sh $package_manager"
    fi

    # Docker specific configuration
    if [ -f /.dockerenv ]; then
        echo "Docker detected. Configuring Neovim for Docker..."
        # Set the language environment variables
        append_env_variable_to_zshrc "LANG" "en_US.UTF-8"
        append_env_variable_to_zshrc "LC_ALL" "en_US.UTF-8"
    fi
    
    # Source zshrc
    source_zshrc
}
    

# Function to create symlinks from the source to the target
create_symlink() {
    local source=$1
    local target=$2
    echo "Creating symlink from $source to $target"
    mkdir -p "$(dirname "$target")" # Ensure the parent directory exists
    # If the target is a directory, remove it
    if [ -d "$target" ]; then
        rm -rf "$target"
    fi
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
}

# Create symlinks for all files in the relative_paths array
for relative_path in "${relative_paths[@]}"; do
    source="$REPO_DIR/$relative_path"
    target="$HOME/$relative_path"
    create_symlink "$source" "$target"
done

# Initialize pkg_manager variable
pkg_manager=""

# Check for package manager, install packages, and source .zshrc file
case $(ps -p $$ -ocomm=) in
  *zsh*)
    # Zsh syntax
    # shellcheck disable=SC2296
    for pm in ${(k)pkg_managers}; do
        if command -v "$pm" >/dev/null 2>&1; then
            echo "$pm found"
            pkg_manager=$pm
            install_packages "$pkg_manager"
            break
        fi
    done
    ;;
  *bash*)
    # Bash syntax
    for pm in "${!pkg_managers[@]}"; do
        if command -v "$pm" >/dev/null 2>&1; then
            echo "$pm found"
            pkg_manager=$pm
            install_packages "$pkg_manager"
            break
        fi
    done
    ;;
esac

# Check if a package manager was found
if [ -z "$pkg_manager" ]; then
    echo "No package manager found"
fi

# Check if zsh is installed
if [ -n "$(command -v zsh)" ]; then
    echo "zsh is installed"

    # Install oh-my-zsh if it's not already installed
    if [ ! -d "$HOME"/.oh-my-zsh ]; then
        echo "Installing oh-my-zsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    # Clone plugins and theme
    case $0 in
    *zsh*)
        # Zsh syntax
        # shellcheck disable=SC2296
        for plugin in ${(k)plugins}; do
            clone_git_repo "$HOME/.oh-my-zsh/custom/plugins/$plugin" "${plugins[$plugin]}"
        done
        ;;
    *bash*)
        # Bash syntax
        for plugin in "${!plugins[@]}"; do
            clone_git_repo "$HOME/.oh-my-zsh/custom/plugins/$plugin" "${plugins[$plugin]}"
        done
        ;;
    esac

    # Check if the theme is already installed
    if [ ! -d "$HOME/.oh-my-zsh/custom/themes/$OH_MY_ZSH_THEME_NAME" ]; then
        echo "Installing $OH_MY_ZSH_THEME_NAME"
        git clone --depth=1 https://github.com/"$OH_MY_ZSH_THEME_REPO".git "$HOME"/.oh-my-zsh/custom/themes/"$OH_MY_ZSH_THEME_NAME"
    fi

    # Install powerlevel10k fonts
    install_powerlevel10k_fonts

    # Source .zshrc file to apply the changes
    if [ -d "$HOME/.oh-my-zsh/custom/themes/$OH_MY_ZSH_THEME_NAME" ]; then
        source_zshrc
    else
        echo "Cannot source .zshrc file because $OH_MY_ZSH_THEME_NAME theme was not found"
    fi

else
    echo "zsh not found, cannot source .zshrc file"
fi

# Install Neovim and configure it
if [ -n "$pkg_manager" ]; then
    install_neovim "$pkg_manager"
    configure_neovim "$pkg_manager"
else
    echo "No package manager found, skipping Neovim installation and configuration"
fi
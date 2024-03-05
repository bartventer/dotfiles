# Dotfiles

This repository contains my personal dotfiles for Unix-like systems. It includes configuration files for the Zsh shell, tmux, and Neovim.

[![Release](https://img.shields.io/github/release/bartventer/dotfiles.svg)](https://github.com/bartventer/dotfiles/releases/latest)
[![License](https://img.shields.io/github/license/bartventer/dotfiles.svg)](LICENSE)

## Prerequisites

This setup is intended for use with any Unix-like system. You should have the following software installed:

| Software | Description                   | Link                           |
| -------- | ----------------------------- | ------------------------------ |
| Zsh      | The Zsh shell with Oh My Zsh. | [Oh My Zsh](https://ohmyz.sh/) |
| Node.js  | JavaScript runtime.           | [Node.js](https://nodejs.org/) |

## Files and Directories

| File/Directory  | Description                                             |
| --------------- | ------------------------------------------------------- |
| `~/.zshrc`      | This file contains configuration for the Zsh shell.     |
| `/.tmux.conf`   | This file contains configuration for tmux.              |
| `/.config/nvim` | This directory contains configuration files for Neovim. |

## Installation

To set up your system using the configurations in this repository, clone this repository and run the `install.sh` script:

```bash
git clone https://github.com/<your-username>/dotfiles.git
cd dotfiles
./install.sh
```

The scipt performs the following steps:

1. Determines the package manager of your system (supports `apt-get`, `dnf`, `yum`, `pacman`, and `brew`).
2. Updates the package lists for upgrades or new package installations.
3. Installs a list of common packages (`git`, `tmux`, `wget`, `fontconfig`) and some distribution-specific packages.
4. Installs Neovim. If the package manager is not supported for Neovim installation, it builds Neovim from source.
5. Creates symbolic links from the home directory to the files in the repository. If a file already exists, it will be replaced by the symlink.
6. If `zsh` is installed, it installs `oh-my-zsh` and a set of `zsh` plugins. It also clones the `powerlevel10k` theme for `oh-my-zsh`.
7. If the `powerlevel10k` theme is successfully installed, it sources the `.zshrc` file to apply the changes.

Please note that if a file already exists in your home directory and is supposed to be symlinked by the script, the existing file will not be backed up and will be replaced by the symlink. Make sure to manually back up any important configuration files in your home directory before running the script.

## Visual Studio Code Settings

If you are using Visual Studio Code, you can modify your settings to automatically sync your dotfiles. Add the following settings to your `settings.json` file:

```json
{
    "dotfiles.repository": "<your-username>/dotfiles",
    "dotfiles.targetPath": "~/dotfiles",
    "dotfiles.installCommand": "install.sh"
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
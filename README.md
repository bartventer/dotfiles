# Dotfiles

This repository contains my personal dotfiles for Unix-like systems. It includes configuration files for the Zsh shell, tmux, and Neovim.

[![Release](https://img.shields.io/github/release/bartventer/dotfiles.svg)](https://github.com/bartventer/dotfiles/releases/latest)
[![License](https://img.shields.io/github/license/bartventer/dotfiles.svg)](LICENSE)

## Table of Contents

-   [Prerequisites](#prerequisites)
-   [OS Support](#os-support)
-   [Files and Directories](#files-and-directories)
-   [Installation](#installation)
-   [Visual Studio Code Settings](#visual-studio-code-settings)
-   [License](#license)

## Prerequisites

This setup is intended for use with any Unix-like system. You should have the following software installed:

| Software                       | Description                   | Installation Command (Arch-based) |
| ------------------------------ | ----------------------------- | --------------------------------- |
| [Zsh](http://www.zsh.org/)     | The Zsh shell with Oh My Zsh. | `sudo pacman -S zsh`              |
| [Node.js](https://nodejs.org/) | JavaScript runtime.           | `sudo pacman -S nodejs`           |
| [npm](https://www.npmjs.com/)  | Node.js package manager.      | `sudo pacman -S npm`              |

## OS Support

This script is designed to work on the following operating systems:

-   Debian-based distributions (like Ubuntu)
-   Red Hat-based distributions (like Fedora, RockyLinux)
-   Arch Linux
-   macOS

The script uses different package managers depending on the OS, including `apt-get`, `dnf`, `yum`, `pacman`, and `brew`.

The `install.sh` script handles the installation of necessary packages. It is designed to recognize the operating system and install the appropriate packages accordingly. For the detailed list of packages and the installation process, please refer to the [install.sh](install.sh) script.

Please note that the script is designed to work with recent versions of these operating systems. If you encounter any issues, please open an issue on the GitHub repository.

## Files and Directories

| File/Directory                 | Description                                             |
| ------------------------------ | ------------------------------------------------------- |
| [`.zshrc`](.zshrc)             | This file contains configuration for the Zsh shell.     |
| [`.tmux.conf`](.tmux.conf)     | This file contains configuration for tmux.              |
| [`.config/nvim`](.config/nvim) | This directory contains configuration files for Neovim. |

## Installation

To set up your system using the configurations in this repository, clone this repository and run the `install.sh` script:

```bash
git clone https://github.com/bartventer/dotfiles.git
cd dotfiles
./install.sh
```

The scipt performs the following steps:

1. Checks and installs `zsh` and `oh-my-zsh`. If not installed, the script exits.
2. Creates symbolic links for certain files from the repository to the home directory.
3. Determines the current shell. If it's not `bash` or `zsh`, the script exits.
4. Identifies the package manager and installs packages. If no package manager is found, the script exits.
5. Clones `oh-my-zsh` plugins and theme.
6. Installs `oh-my-zsh` theme if not already installed.
7. Installs `powerlevel10k` fonts.
8. Sources `.zshrc` file if the `oh-my-zsh` theme is installed. If not, the script exits.
9. Installs and configures `Neovim`.

You can customize the installation using the following command-line options:

| Option | Description                                      | Default                 | Example             |
| ------ | ------------------------------------------------ | ----------------------- | ------------------- |
| `-t`   | Specify a custom theme name for oh-my-zsh.       | `powerlevel10k`         | `agnoster`          |
| `-r`   | Specify a custom theme repository for oh-my-zsh. | `romkatv/powerlevel10k` | `agnoster/agnoster` |
| `-l`   | Specify a language for Neovim configuration.     | `golang`                | `python`            |

You can also run the script in interactive mode with the `--it` or `--interactive` command-line arguments. In interactive mode, you will be prompted to enter the options.

Example:

```bash
./install.sh -t powerlevel10k -r custom-theme-repo -l rust
```

## Visual Studio Code Settings

If you are using Visual Studio Code, you can modify your settings to automatically sync your dotfiles. Add the following settings to your `settings.json` file:

```json
{
    "dotfiles.repository": "bartventer/dotfiles",
    "dotfiles.targetPath": "~/dotfiles",
    "dotfiles.installCommand": "install.sh"
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

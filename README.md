# Dotfiles

This repository contains my personal dotfiles for Unix-like systems. It includes configuration files for the Zsh shell, tmux, and Neovim.

[![Release](https://img.shields.io/github/release/bartventer/dotfiles.svg)](https://github.com/bartventer/dotfiles/releases/latest)
[![License](https://img.shields.io/github/license/bartventer/dotfiles.svg)](LICENSE)

## Table of Contents

-   [Prerequisites](#prerequisites)
-   [Files and Directories](#files-and-directories)
-   [Installation](#installation)
-   [Visual Studio Code Settings](#visual-studio-code-settings)
-   [License](#license)

## Prerequisites

This setup is intended for use with any Unix-like system. You should have the following software installed:

| Software                       | Description                   | Installation Command (Debian-based) |
| ------------------------------ | ----------------------------- | ----------------------------------- |
| [Zsh](http://www.zsh.org/)     | The Zsh shell with Oh My Zsh. | `sudo apt install zsh`              |
| [Node.js](https://nodejs.org/) | JavaScript runtime.           | `sudo apt install nodejs`           |
| [npm](https://www.npmjs.com/)  | Node.js package manager.      | `sudo apt install npm`              |

## Files and Directories

| File/Directory  | Description                                             |
| --------------- | ------------------------------------------------------- |
| `~/.zshrc`      | This file contains configuration for the Zsh shell.     |
| `/.tmux.conf`   | This file contains configuration for tmux.              |
| `/.config/nvim` | This directory contains configuration files for Neovim. |

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

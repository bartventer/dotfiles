# Dotfiles

This repository contains my personal dotfiles for Unix-like systems. It includes configuration files for the Zsh shell, tmux, and Neovim.

[![Release](https://img.shields.io/github/release/bartventer/dotfiles.svg)](https://github.com/bartventer/dotfiles/releases/latest)
[![License](https://img.shields.io/github/license/bartventer/dotfiles.svg)](LICENSE)
[![Build](https://github.com/bartventer/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/bartventer/dotfiles/actions/workflows/ci.yml)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/bartventer/dotfiles)

## Table of Contents

-   [Prerequisites](#prerequisites)
-   [OS Support](#os-support)
-   [Files and Directories](#files-and-directories)
-   [Installation](#installation)
-   [Font Update](#font-update)
-   [Visual Studio Code Settings](#visual-studio-code-settings)
-   [License](#license)

## Prerequisites

### Main Script

You should have the following software installed for the main script:

| Software                                              | Description                   | Installation Command (Arch-based) | Required For    |
| ----------------------------------------------------- | ----------------------------- | --------------------------------- | --------------- |
| [Zsh](http://www.zsh.org/)                            | The Zsh shell with Oh My Zsh. | `sudo pacman -S zsh`              | Shell setup     |
| [Node.js](https://nodejs.org/)                        | JavaScript runtime.           | `sudo pacman -S nodejs`           | Neovim plugins  |
| [npm](https://www.npmjs.com/)                         | Node.js package manager.      | `sudo pacman -S npm`              | Neovim plugins  |
| [jq](https://stedolan.github.io/jq/)                  | Command-line JSON processor.  | `sudo pacman -S jq`               | Scripting       |
| [ps](https://man7.org/linux/man-pages/man1/ps.1.html) | Process status.               | `sudo pacman -S procps-ng`        | Shell detection |
| [Python3](https://www.python.org/)                    | Python programming language.  | `sudo pacman -S python`           | Scripting       |
| [pip](https://pip.pypa.io/en/stable/)                 | Python package installer.     | `sudo pacman -S python-pip`       | Scripting       |
| [venv](https://docs.python.org/3/library/venv.html)   | Python virtual environment.   | Included with Python3             | Scripting       |
| [make](https://www.gnu.org/software/make/)            | Build automation tool.        | `sudo pacman -S make`             | Optional        |

### Font Scraping Script (Optional)

For the optional `update_fonts.sh` script (detailed in the [Font Update](#font-update) section), you should have the following additional software installed:

| Software                                            | Description                  | Installation Command (Arch-based) |
| --------------------------------------------------- | ---------------------------- | --------------------------------- |
| [Python3](https://www.python.org/)                  | Python programming language. | `sudo pacman -S python`           |
| [pip](https://pip.pypa.io/en/stable/)               | Python package installer.    | `sudo pacman -S python-pip`       |
| [venv](https://docs.python.org/3/library/venv.html) | Python virtual environment.  | Included with Python3             |

## OS Support

This script is designed to work on the following operating systems:

-   Debian-based distributions (like Ubuntu)
-   Red Hat-based distributions (like Fedora)
-   Arch Linux
-   macOS

The script uses different package managers depending on the OS, including `apt-get`, `dnf`, `yum`, `pacman`, and `brew`.

The `install.sh` script handles the installation of necessary packages. It is designed to recognize the operating system and install the appropriate packages accordingly. For the detailed list of packages and the installation process, please refer to the [install.sh](install.sh) script.

Please note that the script is designed to work with recent versions of these operating systems. If you encounter any issues, please open an issue on the GitHub repository.

## Files and Directories

| File/Directory                       | Description                                                           |
| ------------------------------------ | --------------------------------------------------------------------- |
| [`.zshrc`](.zshrc)                   | This file contains configuration for the Zsh shell.                   |
| [`.tmux.conf`](.tmux.conf)           | This file contains configuration for tmux.                            |
| [`.config/nvim`](.config/nvim)       | This directory contains configuration files for Neovim.               |
| [`install.sh`](install.sh)           | This script installs the dotfiles on your system.                     |
| [`update_fonts.sh`](update_fonts.sh) | This script updates the fonts.json file.                              |
| [`fonts.json`](config/fonts.json)    | This file contains a list of available fonts.                         |
| [`config.json`](config/config.json)  | This file contains configuration options for the installation script. |

## Installation

To set up your system using the configurations in this repository, clone this repository and run the `install.sh` script:

```bash
git clone https://github.com/bartventer/dotfiles.git
cd dotfiles
./install.sh
```

Or with `make`:

```bash
make install
```

The script performs the following steps:

1. Check and install `zsh` and `oh-my-zsh`.
2. Create symbolic links for files from the repository to the home directory.
3. Identify the package manager, update package lists and install packages.
4. Clone `oh-my-zsh` plugins and theme.
5. Clone and install `tmux` plugins.
6. Install `oh-my-zsh` theme.
7. Install fonts.
8. Install and configure `Neovim`.

You can customize the installation using the following command-line options:

| Option | Description                                                                                                                               | Default                                                                                                          | Example             |
| ------ | ----------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- | ------------------- |
| `-r`   | Specify a custom theme repository for oh-my-zsh.                                                                                          | `romkatv/powerlevel10k`                                                                                          | `agnoster/agnoster` |
| `-l`   | Specify one or more languages for Neovim configuration (comma-separated).                                                                 | `golang`                                                                                                         | `golang,rust`       |
| `-f`   | Specify a font name. See [fonts.json](./fonts.json) for available fonts.<br>See the [Font Update](#font-update) section for more details. | `MesloLGS NF` ([patched for `powerlevel10k`](https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#fonts)) | `Source Code Pro`   |

You can also run the script in interactive mode with the `--it` or `--interactive` command-line arguments. In interactive mode, you will be prompted to enter the options.

Example:

```bash
./install.sh \
-r "agnoster/agnoster" \
-l "golang,rust" \
-f "Source Code Pro"
```

Or with `make`:

```bash
make install r="agnoster/agnoster" l="golang,rust" f="Source Code Pro"
```

## Font Update

To update the fonts, run the `update_fonts.sh` script from the root of the repository. This script scrapes the latest fonts from the [Nerd Fonts](https://www.nerdfonts.com/) website and updates the `fonts.json` file.

```bash
./update_fonts.sh
```

Or with `make`:

```bash
make update_fonts
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

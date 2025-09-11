# Dotfiles

> This repo is due for a major overhaul.

Personal dotfiles for Unix-like systems: Zsh, tmux, Neovim, Doom Emacs, and more.

## Installation

Clone and run the installer:

```bash
git clone https://github.com/bartventer/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

Supports `Arch Linux`, `Debian/Ubuntu`, `Fedora`, and `macOS`. See [install.sh](install.sh) for details.

**Note:**

- Fonts and plugins can be updated via included [tools](tools/).
- Adjust the [config.json](config/config.json) file to customize installation options.

## Editors

Depending on your `EDITOR` setting in `.zshrc`, the installer sets up dependencies for either Neovim or Doom Emacs.

### Neovim

Configuration is in [`.config/nvim`](.config/nvim). Launch with:

```bash
nvim
```

### Doom Emacs

Configuration is in [`.config/emacs`](.config/emacs). Launch with:

```bash
emacs
```

### VSCode

> Works well alongside either Neovim or Doom Emacs.
> If on Arch Linux, you can install `visual-studio-code-bin` from the AUR.

Add this to your `settings.json`:

```json
{
    "dotfiles.repository": "bartventer/dotfiles",
    "dotfiles.targetPath": "~/dotfiles",
    "dotfiles.installCommand": "install.sh"
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

#!/bin/bash

# Check the operating system
OS=$(uname -s)
COPY_CMD=""

case $OS in
Linux)
    # Set copy and paste commands for xclip
    COPY_CMD="'xclip -selection clipboard -i'"
    PASTE_CMD="'xclip -selection clipboard -o'"
    ;;
Darwin)
    # Set copy and paste commands for pbcopy and pbpaste on macOS
    COPY_CMD="pbcopy"
    PASTE_CMD="pbpaste"
    ;;
*)
    echo "Unsupported operating system for clipboard configuration."
    exit 1
    ;;
esac

# Clipboard configuration
CLIPBOARD_CONFIG="
-- Setting up clipboard configuration
vim.g.clipboard = {
  name = '${OS}Clipboard',
  copy = {
    ['+'] = ${COPY_CMD},
    ['*'] = ${COPY_CMD},
  },
  paste = {
    ['+'] = ${PASTE_CMD},
    ['*'] = ${PASTE_CMD},
  },
  cache_enabled = 1,
}"

echo "$CLIPBOARD_CONFIG" >> ~/.config/nvim/lua/core/options.lua
#!/usr/bin/env bash
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Bart Venter.
# Licensed under the MIT License. See https://github.com/bartventer/dotfiles for license information.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/bartventer/dotfiles/tree/main/README.md
# Maintainer: Bart Venter <https://github.com/bartventer>
#-----------------------------------------------------------------------------------------------------------------
#
# Arguments:
#   --dry-run: Show the diff without overwriting init.lua.
#
# Description: This script syncs the plugin configuration files with the init.lua file.
# It generates the init.lua file based on the plugin configuration files.
#
# Usage: ./tools/plugin_config_sync.sh [--dry-run]
#-----------------------------------------------------------------------------------------------------------------

set -euo pipefail

# source init script
# shellcheck disable=SC1091
# shellcheck source=scripts/init.sh
. scripts/init.sh

# Directory containing the lua files
dir="$NVIM_CONFIG_DIR/lua/core/plugin_config"
if [[ ! -d $dir ]]; then
    echo "Error: Directory not found: $dir"
    tree "$DOTFILES_DIR/nvim/lua/core" --noreport
    exit 1
fi

# Count the number of require statements in the original init.lua
require_count_before=$(grep -c 'require' "$dir"/init.lua)

# Temporary file for new content
temp_file=$(mktemp)

# Generate the new init.lua content
find "$dir" -name "*.lua" ! -name "init.lua" |
    sed 's#^.*/core/#require("core.#' |
    sed 's/.lua$//g' |
    sed 's#/#.#g' |
    sed 's/$/")/' |
    sort >"$temp_file"

# Compare the current init.lua with the new content
diff_file=$(mktemp)
diff -y --color=always "$dir"/init.lua "$temp_file" >"$diff_file" || true

# Count the number of require statements in the new init.lua
require_count_after=$(grep -c 'require' "$temp_file")

# Calculate the difference in require statements
require_diff=$((require_count_after - require_count_before))

# Print diff and stats
echo -e "Diff summary:"
cat "$diff_file"
echo -e "\nStats:"
echo -e "Require statements before: $require_count_before\nRequire statements after: $require_count_after\nRequire statements diff: $require_diff"

# Cleanup
rm "$diff_file"

# Check if dry run option is set
if [[ "${1:-}" == "--dry-run" ]]; then
    echo "Dry run completed. No changes were made to init.lua."
    rm "$temp_file"
    exit 0
fi

# Prompt user to overwrite init.lua
read -p "Do you want to overwrite init.lua? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mv "$temp_file" "$dir"/init.lua
    echo "init.lua has been updated."
else
    rm "$temp_file"
    echo "No changes were made to init.lua."
fi

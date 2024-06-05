#!/usr/bin/env bash

# This script is a system cleanup script.

set -euo pipefail

# clean_vscode Cleans up the VSCode extensions directory by removing duplicate extensions.
clean_vscode() {
    echo -e "\n🧽 Cleaning up the VSCode extensions..."

    local ext_dir=~/.vscode/extensions
    cd "$ext_dir"
    if [[ "$(pwd)" != "$ext_dir" ]]; then
        echo "🚫 Error: Failed to change to the VSCode extensions directory."
        exit 1
    fi

    echo "📁 Current directory: $(pwd)"
    echo "🔎 Looking for duplicate extensions..."
    local -A exts_to_delete=()
    local total_size=0
    local total_exts=0
    for ext in $(
        find . -maxdepth 1 -type d |     # List all directories in the current directory
            cut -f2 -d'/' |              # Extract the extension name
            rev | cut -d'-' -f2- | rev | # Remove the version number
            sort |                       # Sort the extensions
            uniq -d                      # Extract the extensions with more than one occurrence
    ); do
        local duplicates
        duplicates=$(
            find . -maxdepth 1 -name "${ext}*" -type d | # List all directories that start with the extension name
                sort -Vr |                               # Sort the directories by version number in descending order
                tail -n +2                               # Skip the first directory (the latest version)
        )
        exts_to_delete[$ext]=$duplicates
        for duplicate in $duplicates; do
            total_size=$((total_size + $(du -s "$duplicate" | cut -f1)))
            total_exts=$((total_exts + 1))
        done
    done

    echo "📝 The following duplicate extensions will be removed:"
    for ext in "${!exts_to_delete[@]}"; do
        echo "$ext:"
        echo "  - Latest version to keep: $(find . -maxdepth 1 -name "${ext}*" -type d | sort -Vr | head -n 1)"
        echo "  - Duplicates to delete:"
        for duplicate in ${exts_to_delete[$ext]}; do
            echo "    - $duplicate (Size: $(du -sh "$duplicate" | cut -f1))"
        done
    done
    if [[ $total_exts -eq 0 ]]; then
        echo "✔️ No duplicate extensions found."
        return
    fi

    echo "🔢 Total number of extensions to be deleted: $total_exts"
    echo "💾 Total size of extensions to be deleted: $(echo $total_size | awk '{ sum = $1 / 1024 ; printf "%.2fMB\n", sum}')"
    echo "⚠️ Warning: This operation is irreversible. Make sure to back up any important data before proceeding."s
    echo "📂 cwd: $(pwd)"
    echo "📝 Commands to be executed:"
    for ext in "${!exts_to_delete[@]}"; do
        for duplicate in ${exts_to_delete[$ext]}; do
            echo "  rm -rf $duplicate"
        done
    done
    read -r -p "🤔 Are you sure you want to proceed? [y/N] " answer
    if [[ $answer != [Yy]* ]]; then
        echo "🛑 Operation aborted."
        return
    fi

    echo "💽 Creating a backup of the VSCode extensions directory..."
    local backup_dir="${ext_dir}_backup"
    echo "📂 Backup directory: $backup_dir"
    cp -r "$ext_dir" "$backup_dir"

    echo "🗑️ Removing duplicate extensions..."
    for ext in "${!exts_to_delete[@]}"; do
        for duplicate in ${exts_to_delete[$ext]}; do
            rm -rf "$duplicate"
        done
    done
    echo "✔️ Done! All duplicate extensions have been removed."

    echo "🗑️ Removing the backup..."
    echo "📂 Backup directory: $backup_dir"
    rm -rf "$backup_dir"
    echo "✔️ Done! The backup has been removed."
}

# clean_cache Cleans up the cache directory by removing all files and directories.
clean_cache() {
    echo -e "\n🧽 Cleaning up the cache..."

    local cache_dir=~/.cache
    if [[ ! "$(ls -A $cache_dir)" ]]; then
        echo "✔️ Cache is empty. Nothing to clean."
        return
    fi
    local total_size
    total_size=$(du -sh "$cache_dir" | cut -f1)

    echo "💾 Total size of cache: $total_size"
    echo "⚠️ Warning: This operation is irreversible. Make sure to back up any important data before proceeding."
    echo "📝 The following directories will be removed from the cache (sorted by size):"
    find "$cache_dir" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -print0 |
        xargs -0 du -sh |                 # List the size of each directory
        sort -hr |                        # Sort the directories by size in descending order
        awk '{printf "%7s %s\n", $1, $2}' # Format the output to display the size and directory name

    echo "📂 cwd: $(pwd)"
    echo "📝 Command to be executed:"
    echo "  rm -rf $cache_dir"
    read -r -p "🤔 Are you sure you want to proceed? [y/N] " answer
    if [[ $answer != [Yy]* ]]; then
        echo "🛑 Operation aborted."
        return
    fi
    echo "🗑️ Removing the cache..."
    sudo rm -rf ~/.cache/*
    echo "✔️ Done! The cache has been removed."
}

# clean_go Cleans up the Go cache by removing all files and directories.
clean_go() {
    echo -e "\n🧽 Cleaning up the Go cache..."
    if [[ ! "$(command -v go)" ]]; then
        return
    fi
    echo "📂 Current directory: $(pwd)"
    echo "📝 Command to be executed:"
    echo "  go clean -cache -modcache -i -r"
    read -r -p "🤔 Are you sure you want to proceed? [y/N] " answer
    if [[ $answer != [Yy]* ]]; then
        echo "🛑 Operation aborted."
        return
    fi
    go clean -cache -modcache -i -r
    echo "✔️ Done! The Go cache has been removed."
}

main() {
    echo "🧹 System cleanup script"
    (clean_vscode)
    (clean_cache)
    (clean_go)
    echo "✅ Done! System cleanup completed."
}

main

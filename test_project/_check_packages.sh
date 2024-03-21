#!/bin/bash

# shellcheck disable=SC1091
source test-utils.sh
source ../scripts/util.sh

check_packages() {
    # Initialize the status
    status=0

    local distro=$(detect_distro)
    echo "Detected distribution: $distro"

    # Get the config file location from the first argument
    config_file="$1"

    # Load the common packages from the JSON file
    common_packages=$(jq -r ".common_packages[]" "$config_file")

    # Convert the common packages string into an array
    IFS=' ' read -r -a common_packages_array <<< "$common_packages"

    for package in "${common_packages_array[@]}"
    do
        if ! check "${package}" "command -v ${package}"; then
            status=1
        fi
    done

    # Load the distro-specific packages from the JSON file
    packages=$(jq -r ".distro_packages.\"${distro}\"" "$config_file")

    if [ -z "$packages" ]; then
        echo "No packages found for the ${distro} distribution in the config file."
        status=1
    else
        # Convert the packages string into an array
        IFS=' ' read -r -a packages_array <<< "$packages"

        for package in "${packages_array[@]}"
        do
            # Packages to rename
            case "$package" in
                "fd-find")
                    case "$distro" in
                        "debian"|"ubuntu") package="fdfind" ;;
                        "fedora") package="fd" ;;
                    esac
                    ;;
                "ripgrep") package="rg" ;;
            esac

            # Check if the package is installed
            case "$package" in
                "python3-venv")
                    if ! check "${package}" "python3 -m venv --help &>/dev/null"; then
                        status=1
                    fi
                    ;;
                "glibc-locale-source"|"glibc-langpack-en"|"python3-devel")
                    if ! check "${package}" "rpm -q ${package}"; then
                        status=1
                    fi
                    ;;
                "locales")
                    if ! check "${package}" "locale -a"; then
                        status=1
                    fi
                    ;;
                lua*)
                    if ! check "${package}" "lua -v"; then
                        status=1
                    fi
                    ;;
                "tree-sitter-cli")
                    if ! check "${package}" "pacman -Q ${package}"; then
                        status=1
                    fi
                    ;;
                *)
                    if ! check "${package}" "command -v ${package}"; then
                        status=1
                    fi
                    ;;
            esac
        done
    fi

    return $status
}
#!/bin/bash

# shellcheck disable=SC1091
source test-utils.sh

check_packages() {
    # Initialize the status
    status=0

    # Detect the current distribution
    distro=""
    if [ "$(uname)" == "Darwin" ]; then
        distro="macos"
    else
        # shellcheck disable=SC2002
        distro=$(cat /etc/os-release | grep "^ID=" | cut -d= -f2 | tr -d '"')
    fi
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
            if ! check "${package}" "command -v ${package}"; then
                status=1
            fi
        done
    fi

    return $status
}
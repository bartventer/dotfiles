#!/bin/bash

# Check if an argument is provided
if [ "$#" -ne 1 ]; then
    log_error "Usage: $0 <path_to_options.lua>"
    exit 1
fi

log_info "Setting up clipboard..."

# Target options file
OPTIONS_FILE="$1"

# Check the operating system
OS=$(uname -s)
# Set the copy and paste commands
COPY_CMD=""
PASTE_CMD=""

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
    log_error "Unsupported operating system for clipboard configuration."
    exit 1
    ;;
esac

# Unique part of the configuration
UNIQUE_CONFIG_PART="name = '${OS}Clipboard',"

# Clipboard configuration
CLIPBOARD_CONFIG="
-- Setting up clipboard configuration
vim.g.clipboard = {
  ${UNIQUE_CONFIG_PART}
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

# Check if the configuration already exists in the options file, by checking the unique part
if ! grep -q "$UNIQUE_CONFIG_PART" "$OPTIONS_FILE"; then
    # If the configuration does not exist, append it
    echo "$CLIPBOARD_CONFIG" >> "$OPTIONS_FILE"
    # If on Linux and in docker container; notify user that X11 forwarding is required from the host machine
    if [ "$OS" = "Linux" ] && [ -f /.dockerenv ]; then
        printf "
        ${YELLOW}Warning:${NC}
        You are running inside a docker container. In order to use the clipboard feature, you need to enable X11 forwarding from the host machine.
        Please add the following lines to your docker-compose.yml file:

        services:
          your-service:
            environment:
              - DISPLAY=unix%s
            volumes:
              - /tmp/.X11-unix:/tmp/.X11-unix

        And run the following command on your host machine:

        xhost +local:docker

        If you have already configured X11 forwarding, you can ignore this message.
        " "$DISPLAY"
    else
        log_success "Clipboard configuration added to $OPTIONS_FILE."
    fi
fi

log_success "Clipboard setup complete"
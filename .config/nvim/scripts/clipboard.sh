#!/bin/bash

# Check if an argument is provided
if [ "$#" -ne 1 ]; then
  log_error "Usage: $0 <path_to_options.lua>"
  exit 1
fi

log_info "Setting up clipboard..."

# Target options file
OPTIONS_FILE="$1"

# Unique comment for the clipboard configuration
CLIPBOARD_COMMENT="-- OS-specific clipboard configuration"

# Clipboard configuration
CLIPBOARD_CONFIG="
${CLIPBOARD_COMMENT}
-- Check the operating system and set the copy and paste commands
local OS = io.popen('uname -s'):read('*l')
local COPY_CMD = ''
local PASTE_CMD = ''

if OS == 'Linux' then
  COPY_CMD = 'xclip -selection clipboard -i'
  PASTE_CMD = 'xclip -selection clipboard -o'
elseif OS == 'Darwin' then
  COPY_CMD = 'pbcopy'
  PASTE_CMD = 'pbpaste'
else
  print('Unsupported operating system for clipboard configuration.')
  return
end

-- Check if copy and paste commands are available
if os.execute('command -v ' .. COPY_CMD) == 0 and os.execute('command -v ' .. PASTE_CMD) == 0 then
    vim.g.clipboard = {
        name = OS .. 'Clipboard',
        copy = {
            ['+'] = COPY_CMD,
            ['*'] = COPY_CMD,
        },
        paste = {
            ['+'] = PASTE_CMD,
            ['*'] = PASTE_CMD,
        },
        cache_enabled = 1
    }
else
    print('Copy or paste command not found. Clipboard configuration not set.')
end
"

# Check if the configuration already exists in the options file
if ! grep -q "${CLIPBOARD_COMMENT}" "$OPTIONS_FILE"; then
  # If the configuration does not exist, append it
  echo "$CLIPBOARD_CONFIG" >>"$OPTIONS_FILE"
  log_success "Clipboard configuration added to $OPTIONS_FILE."
fi

log_success "Clipboard setup complete"

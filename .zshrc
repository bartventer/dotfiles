# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
prompt_file="${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt.zsh"

# Check if the prompt file is readable
# shellcheck disable=SC1090
[[ -r "$prompt_file" ]] && source "$prompt_file"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Go path: # https://pkg.go.dev/cmd/go#hdr-GOPATH_environment_variable
if command -v go &>/dev/null; then
  export GOPATH=$HOME/go
  # Add $GOPATH/bin to the PATH
  [[ ":$PATH:" != *":$GOPATH/bin:"* ]] && export PATH=$PATH:$GOPATH/bin
fi

# Yarn global bin path
if command -v yarn &>/dev/null; then
  _yarn_global_bin=$(yarn global bin)
  [[ -d $_yarn_global_bin ]] && export PATH=$PATH:$_yarn_global_bin
fi

# Add default paths to PATH
for dir in \
  $HOME/bin \
  /usr/local/bin \
  /usr/local/go/bin \
  /usr/local/lua/bin \
  $HOME/.config/emacs/bin \
  $HOME/.local/share/nvim/mason/bin \
  $HOME/.local/bin; do
  [[ -d "$dir" && ":$PATH:" != *":$dir:"* ]] && PATH=$PATH:$dir
done

export PATH

# Npm config to allow user-wide installations (https://wiki.archlinux.org/title/node.js_)
export npm_config_prefix="$HOME/.local"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# shellcheck disable=SC2034
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# shellcheck disable=SC2034
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh-history-substring-search
)
# Arch Linux plugin
[[ -f /etc/arch-release ]] && plugins+=(archlinux)
# Tmux plugin
[[ -f ~/.tmux.conf ]] && plugins+=(tmux)

# shellcheck disable=SC1091
# shellcheck disable=SC2086
source $ZSH/oh-my-zsh.sh
# Tmux config: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/tmux#configuration-variables
# shellcheck disable=SC2034
ZSH_TMUX_AUTOSTART=true # Automatically starts tmux
# shellcheck disable=SC2034
ZSH_TMUX_CONFIG="$HOME/.tmux.conf" # Path to tmux config file

# User configuration
export MYVIMRC=$HOME/.config/nvim/init.lua

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='mvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias python=python3
alias nvconfigdir="cd ~/.config/nvim"
alias nvconfig="cd ~/.config/nvim && nvim"
alias brc="nvim ~/.bashrc"
alias zrc="nvim ~/.zshrc"
alias nv="nvim"
alias lc='colorls -lA --sd'
alias dotfiles="cd ~/dotfiles"
alias tmux_source="tmux source-file ~/.tmux.conf"

# Locally defined aliases
# shellcheck disable=SC1090
[[ -f ~/.aliases ]] && source ~/.aliases

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# shellcheck disable=SC1090
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Source powerlevel10k theme
POWERLEVEL10K_THEME="$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"
# shellcheck disable=SC1090
[[ -f "$POWERLEVEL10K_THEME" ]] && source "$POWERLEVEL10K_THEME"

# Source local zsh configuration
# shellcheck disable=SC1090
[[ -f ~/.zsh_local ]] && source ~/.zsh_local

# Shell auto-completion for zsh
autoload -Uz compinit && compinit

# GPG Key
# shellcheck disable=SC2155
export GPG_TTY=$(tty)

# Run neofetch
if command -v neofetch &>/dev/null; then neofetch; fi

# ==============================================================================
# 1. Environment & Paths
# ==============================================================================

# XDG base dirs
export XDG_CONFIG_HOME="$HOME/.config"

# Editor and themes
export EDITOR=nvim
export BAT_THEME="base16"

# Base PATHs
export PATH="$HOME/.local/bin:$PATH"

# navi looks its cheatsheets up here. The config file cannot hold the path: it
# does not expand "~", and the repo sits under a different $HOME on macOS and on
# NixOS.
export NAVI_PATH="$HOME/dotfiles/configs/navi/cheats"

# ==============================================================================
# 2. Zinit & Plugins
# ==============================================================================

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Pure prompt
zinit ice pick"async.zsh" src"pure.zsh"
zinit light sindresorhus/pure

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light MichaelAquilina/zsh-you-should-use

# Completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# ==============================================================================
# 3. Keybindings & History
# ==============================================================================

bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

HISTSIZE=10000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# ==============================================================================
# 4. Completion styling
# ==============================================================================

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# ==============================================================================
# 5. Integrations (fzf, zoxide, direnv, atuin, navi)
# ==============================================================================

eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
command -v direnv >/dev/null && eval "$(direnv hook zsh)"

# atuin owns ctrl-r. --disable-up-arrow leaves the arrow keys, and the ^p/^n
# bindings above, on zsh's own prefix history search.
eval "$(atuin init zsh --disable-up-arrow)"

# navi on ctrl-g: browse the cheatsheets and drop the command on the prompt
eval "$(navi widget zsh)"

# OrbStack
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# ==============================================================================
# 6. Aliases & Functions
# ==============================================================================

[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases

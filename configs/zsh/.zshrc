# ==============================================================================
# 1. Environment & Paths
# ==============================================================================

# Detect OS
[[ "$OSTYPE" == "darwin"* ]] && IS_MACOS=true || IS_MACOS=false

# XDG base dirs
export XDG_CONFIG_HOME="$HOME/.config"

# Editor and themes
export EDITOR=nvim
export BAT_THEME="base16"

# Base PATHs
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

if $IS_MACOS; then
  export PATH="/Users/gauthierseyzeriat/.antigravity-ide/antigravity-ide/bin:$PATH"
  export PATH="/opt/anaconda3/bin:$PATH"
  
  # Bun
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
  [ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
fi

# ==============================================================================
# 2. Oh My Zsh & Prompt
# ==============================================================================

export ZSH="$HOME/.oh-my-zsh"
DISABLE_AUTO_TITLE="true"
ZSH_THEME=""

# Note: The 'nvm' plugin automatically sources NVM for you
plugins=(
  git
  nvm
  you-should-use
  zsh-autosuggestions
  zsh-bat
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Pure prompt
if $IS_MACOS; then
  fpath+=("$(brew --prefix)/share/zsh/site-functions")
else
  fpath+=("$HOME/.zsh/pure")
fi
autoload -U promptinit; promptinit
prompt pure

# Catppuccin Mocha syntax highlighting
source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh

# ==============================================================================
# 3. Integrations (fzf, zoxide, etc.)
# ==============================================================================

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Zoxide
eval "$(zoxide init zsh)"

# ==============================================================================
# 4. macOS Specific Tools (OrbStack, SDKMAN, Conda)
# ==============================================================================

if $IS_MACOS; then
  # OrbStack
  source ~/.orbstack/shell/init.zsh 2>/dev/null || :

  # SDKMAN
  export SDKMAN_DIR="$HOME/.sdkman"
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

  # Conda
  __conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  elif [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
    . "/opt/anaconda3/etc/profile.d/conda.sh"
  fi
  unset __conda_setup
fi

# ==============================================================================
# 5. Aliases & Functions
# ==============================================================================

[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases
[ -f ~/.zsh_functions ] && source ~/.zsh_functions

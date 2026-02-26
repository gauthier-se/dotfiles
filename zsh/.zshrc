# Oh My Zsh Configuration
export ZSH="$HOME/.oh-my-zsh"
DISABLE_AUTO_TITLE="true"

# Leave empty as the theme is managed by Pure prompt below.
ZSH_THEME=""

# Plugins configuration.
# Note: zsh-syntax-highlighting must always be the last plugin in the array.
plugins=(
  git
  nvm
  you-should-use
  zsh-autosuggestions
  zsh-bat
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Prompt Configuration (Pure)
fpath+=("$(brew --prefix)/share/zsh/site-functions")
autoload -U promptinit; promptinit
prompt pure

# Syntax Highlighting Theme (Catppuccin Mocha)
source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh

# Aliases
alias ll="ls -lshA"
alias la="ls -A"
alias ..="cd .."
alias ...="cd ../.."
alias c="clear"
alias update="brew update && brew upgrade && brew cleanup"
alias vi="nvim"
alias mux="tmuxinator"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Zoxide
eval "$(zoxide init zsh)"

# OrbStack
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# opencode
export PATH=/Users/gauthierseyzeriat/.opencode/bin:$PATH

# Local bin
export PATH="$HOME/.local/bin:$PATH"

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# ── oh-my-zsh ────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(git nvm)

source $ZSH/oh-my-zsh.sh

# ── Pure prompt ───────────────────────────────────────────────────────────────
fpath+=("$(brew --prefix)/share/zsh/site-functions")
autoload -U promptinit; promptinit
prompt pure

# ── Aliases ───────────────────────────────────────────────────────────────────
alias ll="ls -lshA"
alias la="ls -A"
alias ..="cd .."
alias ...="cd ../.."
alias c="clear"

# ── fzf ───────────────────────────────────────────────────────────────────────
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ── zoxide ────────────────────────────────────────────────────────────────────
eval "$(zoxide init zsh)"

# ── OrbStack ──────────────────────────────────────────────────────────────────
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

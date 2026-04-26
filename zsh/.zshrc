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
alias ....="cd ../../.."
alias c="clear"
alias vi="nvim"
alias mux="tmuxinator"
alias openzs="vi ~/dotfiles/zsh/.zshrc"
alias sourcezs="source ~/.zshrc"
alias update="brew update && brew upgrade && brew cleanup"

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

# bun completions
[ -s "/Users/gauthierseyzeriat/.bun/_bun" ] && source "/Users/gauthierseyzeriat/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export EDITOR=nvim

# Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# Detect OS
[[ "$OSTYPE" == "darwin"* ]] && IS_MACOS=true || IS_MACOS=false

# XDG base dirs (so macOS tools like lazygit/lazydocker use ~/.config/)
export XDG_CONFIG_HOME="$HOME/.config"

# Oh My Zsh Configuration
export ZSH="$HOME/.oh-my-zsh"
DISABLE_AUTO_TITLE="true"
ZSH_THEME=""

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
if $IS_MACOS; then
  alias update="brew update && brew upgrade && brew cleanup"
  alias startdocker="orb"
else
  alias update="yay -Syu"
  alias startdocker="sudo systemctl start docker"
fi

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Zoxide
eval "$(zoxide init zsh)"

# Yazi
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export EDITOR=nvim
export BAT_THEME="base16"

# macOS only
if $IS_MACOS; then
  # OrbStack
  source ~/.orbstack/shell/init.zsh 2>/dev/null || :

  # SDKMAN
  export SDKMAN_DIR="$HOME/.sdkman"
  [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

  # bun
  [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"

  # conda
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
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

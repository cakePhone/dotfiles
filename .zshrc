export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$HOME/.cargo/bin:$HOME/.local/share/bob/nvim-bin:$PATH

export ZSH="/usr/share/oh-my-zsh"

ZSH_THEME="nicoulaj"

plugins=(git calc zsh-autosuggestions fast-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

source ~/dotfiles/scripts/check-updates.zsh

alias vi=nvim
alias ccwall="gcc -Wall -Wextra -pedantic -O1 -fsanitize=address -fno-omit-frame-pointer -g"
alias vibes="git status"
alias crime="git commit -m"
alias gimme="git pull"
alias yeet="git push"

alias ok-boomer="git branch"
alias dip="git checkout"

alias pls="sudo"

alias cd="z"

if [[ !(which code) ]] then;
    alias code="code-oss"
fi

# bun completions
[ -s "/home/oreo/.bun/_bun" ] && source "/home/oreo/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export EDITOR="nvim"

# force wayland
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export OZONE_PLATFORM=wayland

function accept-line-or-ls() {
  if [[ -z $BUFFER ]]; then
    echo ""
    ls
  fi

  zle accept-line
}
zle -N accept-line-or-ls
bindkey '^M' accept-line-or-ls

if [[ ! ($(printenv | grep -c "VSCODE_") -gt 0 || $(printenv | grep -c "NVIM") -gt 0 || $(printenv | grep -c "PYCHARM_JDK") -gt 0 || $(printenv | grep -c "WEBIDE_") -gt 0 || $(printenv | grep -c "INTELLIJ_") -gt 0 || $(printenv | grep -c "CLION_") -gt 0 || $(printenv | grep -c "RIDER_") -gt 0 || $(printenv | grep -c "GOLAND_") -gt 0) ]]; then
  alias clear="clear && fastfetch"
  fastfetch
  get_update_status
fi


bindkey -v

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
eval "$(zoxide init zsh)"

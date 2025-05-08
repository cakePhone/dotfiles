export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$HOME/.cargo/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="nicoulaj"

plugins=(git zsh-vi-mode)

source $ZSH/oh-my-zsh.sh

alias vi=lvim
alias ccwall="gcc -Wall -Wextra -pedantic -O1 -fsanitize=address -fno-omit-frame-pointer -g"


# bun completions
[ -s "/home/oreo/.bun/_bun" ] && source "/home/oreo/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export EDITOR="lvim"

# force wayland
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export OZONE_PLATFORM=wayland

function accept-line-or-ls() {
  if [[ -z $BUFFER ]]; then
    echo ""
    ls -lh --color=always --group-directories-first -S | awk 'NR>1 {print $5, $9}' | column -t
  fi

  zle accept-line
}
zle -N accept-line-or-ls
bindkey '^M' accept-line-or-ls

if [[ ! ($(printenv | grep -c "VSCODE_") -gt 0 || $(printenv | grep -c "NVIM") -gt 0) ]]; then
  alias clear="clear && fastfetch"
  fastfetch
fi

bindkey -v


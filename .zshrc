export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$HOME/.cargo/bin:$HOME/.local/share/bob/nvim-bin:$PATH

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

export ZSH="/usr/share/oh-my-zsh"

ZSH_THEME="nicoulaj"

plugins=(git)

source $ZSH/oh-my-zsh.sh

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

alias npm="bun"
alias npx="bunx"

# bun completions
[ -s "/home/oreo/.bun/_bun" ] && source "/home/oreo/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export EDITOR="nvim"

should_show_fastfetch() {
  [[ -z ${parameters[(I)VSCODE_*]} && -z ${parameters[(I)NVIM]} && -z ${parameters[(I)PYCHARM_JDK*]} && -z ${parameters[(I)WEBIDE_*]} && -z ${parameters[(I)INTELLIJ_*]} && -z ${parameters[(I)CLION_*]} && -z ${parameters[(I)RIDER_*]} && -z ${parameters[(I)GOLAND_*]} && -z ${parameters[(I)ZED_*]} && "${TERM_PROGRAM-}" != "zed" ]]
}

if should_show_fastfetch; then
  alias clear="clear && fastfetch"
  fastfetch
fi

autoload -Uz compinit && compinit

export MAKEFLAGS="-j$(nproc)"

eval "$(zoxide init zsh)"

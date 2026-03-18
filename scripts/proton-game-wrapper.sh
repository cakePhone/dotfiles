#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
    echo "Usage: proton-game-wrapper.sh <command> [args...]" >&2
    exit 1
fi

# Prevent IME/input-method interference in some Proton/Xwayland titles.
unset GTK_IM_MODULE
unset QT_IM_MODULE
unset SDL_IM_MODULE
export XMODIFIERS="@im=none"

# Ubisoft Connect overlay can break focus/input in some games.
export UPLAY_DISABLE_OVERLAY=1

exec "$@"

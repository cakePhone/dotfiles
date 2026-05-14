#!/usr/bin/env zsh

export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$HOME/.cargo/bin:$HOME/.local/share/bob/nvim-bin:$PATH"

export LANG=en_GB.UTF-8
export LC_CTYPE=en_GB.UTF-8

export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=niri
export XDG_CURRENT_DESKTOP=niri
export QT_QPA_PLATFORMTHEME=qt6ct
export LIBVA_DRIVER_NAME=""
export GDK_SCALE=1
export ELECTRON_OZONE_PLATFORM_HINT=auto
export NVD_BACKEND=direct
export GTK_IM_MODULE=simple
export ZED_WINDOW_DECORATIONS=server

if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" = "1" ]; then
  systemctl --user --wait start niri.service
fi

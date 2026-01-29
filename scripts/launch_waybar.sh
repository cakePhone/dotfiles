#!/usr/bin/env bash
# Relaunch waybar safely: kill existing instance and start a detached one
set -euo pipefail

pkill -x waybar || true
# Start waybar detached so this script exits quickly (avoids blocking Hyprland startup)
nohup waybar -c "$HOME/dotfiles/waybar/config.jsonc" -s "$HOME/dotfiles/waybar/style.css" >/dev/null 2>&1 &
disown

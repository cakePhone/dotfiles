#!/usr/bin/env bash
set -euo pipefail

start_if_missing() {
    local proc="$1"
    shift

    if ! pgrep -xu "$USER" -x "$proc" >/dev/null 2>&1; then
        "$@" >/dev/null 2>&1 &
    fi
}

start_if_missing pipewire pipewire
start_if_missing wireplumber wireplumber
start_if_missing pipewire-pulse pipewire-pulse

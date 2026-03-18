#!/bin/sh

WM_TARGET="${2:-auto}"

# Constants
POWER_SAVE_PROFILE="power-saver"
PERFORMANCE_PROFILE="balanced"
POWER_UNPLUG_SOUND="power-unplug"
POWER_PLUG_SOUND="power-plug"

# Apply a power profile and notify
set_profile() {
    local profile=$1
    local message=$2

    if [ "$profile" = "$POWER_SAVE_PROFILE" ]; then
        ~/dotfiles/scripts/power-manager.sh powersave "$WM_TARGET"
    else
        ~/dotfiles/scripts/power-manager.sh performance "$WM_TARGET"
    fi

    notify-send "Power Profile" "$message"
}

# Toggle between powersave and performance mode
toggle_mode() {
    local current_profile
    if command -v powerprofilesctl >/dev/null 2>&1; then
        current_profile=$(powerprofilesctl get)
    elif command -v tlp-stat >/dev/null 2>&1; then
        current_profile=$(tlp-stat --mode)
    else
        current_profile="unknown"
    fi

    if [ "$current_profile" = "battery" ] || [ "$current_profile" = "power-saver" ]; then
        set_profile "$POWER_SAVE_PROFILE" "Switched to $POWER_SAVE_PROFILE mode"
    else
        set_profile "$PERFORMANCE_PROFILE" "Switched to $PERFORMANCE_PROFILE mode"
    fi
}

# Play a sound notification
play_sound() {
    canberra-gtk-play -i "$1"
}

# Main logic
power_state=$(
    upower -i "$(upower -e | grep BAT)" | awk '/state/ {print $2}'
)

if [ "$1" = "true" ]; then
    # On boot
    if [ "$power_state" = "discharging" ]; then
        set_profile "$POWER_SAVE_PROFILE" "Switched to $POWER_SAVE_PROFILE mode"
    else
        set_profile "$PERFORMANCE_PROFILE" "Switched to $PERFORMANCE_PROFILE mode"
    fi
else
    # Plug/unplug event
    if [ "$power_state" = "discharging" ]; then
        play_sound "$POWER_UNPLUG_SOUND"
        set_profile "$POWER_SAVE_PROFILE" "Switched to $POWER_SAVE_PROFILE mode"
    else
        play_sound "$POWER_PLUG_SOUND"
        toggle_mode
    fi
fi
